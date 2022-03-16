/*
This nodejs script loads and saves the image to make a monitoring images
requires PORT and USER_DATA env variables and the uuid to check as argument
*/

process.on('unhandledRejection', up => { throw up });
process.on('UnhandledPromiseRejectionWarning', err => process.exit(1) ); //this does nothing.

const puppeteer = require('puppeteer');
const fse = require('fs-extra');
const timeout = (ms) => new Promise(resolve => setTimeout(resolve, ms));
const uuid = process.argv[2];
const prefix = process.argv.length === 4 ? process.argv[3] : '';
console.log(`Parsing ${uuid}`);

(async () => {
    //for some reason I cannot get npm to install chromium on centos.
  const browser = await puppeteer.launch({headless: true, args: ['--no-sandbox',
                                                                        '--disable-setuid-sandbox',
                                                                        '--disable-web-security']});
   //{headless: false} if dev.
  const page = await browser.newPage();
  await page.setViewport({
                          width: 1000,
                          height: 700,
                          deviceScaleFactor: 1,
                        });
  page
    .on('console', message =>
      console.log(`${message.type().substr(0, 3).toUpperCase()} ${message.text()}`))
    .on('pageerror', ({ message }) => console.log(message))
    .on('response', response =>
      console.log(`${response.status()} ${response.url()}`))
    .on('requestfailed', request =>
      console.log(`${request.failure().errorText} ${request.url()}`));

    //await page.setRequestInterception(true);
    //page.on('request', (request) => ...); // block requests?
    await page.goto(`http://localhost:${process.env.PORT}/data/${uuid}?columns_viewport=6&no_user=1&offline=1&no_buttons=1&key=None`);
    let labels = ['Initial view'];
    //conf.
    await page.setViewport({
                          width: 1000,
                          height: 700,
                          deviceScaleFactor: 1,
                        });
    await page.click('body');
    await page.evaluate( () => $('#viewport img').click() ? $('#viewport img').length : undefined );
    await page._client.send('Page.setDownloadBehavior', {behavior: 'allow',
                                                         downloadPath: `${process.env.USER_DATA}/monitor/`});


    //navigation lock
    page.on('request', req => {
    if (req.isNavigationRequest() && req.frame() === page.mainFrame() && req.url() !== url) {
      console.log(`request: ${req.url()}`);
      console.log('abort');
      req.abort('aborted');
    } else {
      req.continue();
    }
    });
    await page.setRequestInterception(true);
    await timeout(4000); //safe side//
    // links
    const nLinks = await page.evaluate( () => $('.prolink').length );
    // open:
    const saver = async(filename) => {
        const response = await page.evaluate(() => new Promise((resolve, reject) => {
          NGL.getStage()
              .makeImage({trim: true, antialias: false, transparent: false})
              .then((blob) => {
                  const reader = new FileReader();
                  reader.readAsBinaryString(blob);
                  reader.onload = () => resolve(reader.result);
                  reader.onerror = () => reject('Error occurred while reading binary string');
              })
          })
        );
        const file = Buffer.from(response , 'binary');
        fse.writeFileSync(filename, file);
    };
    await saver(`${process.env.USER_DATA}/monitor/${prefix}${uuid}-0.png`);

    // start clicking!
    for (let i=0; i < Math.min(nLinks, 100); i++) {
        await page.evaluate((index) => $(`.prolink:eq(${index})`).click(), i);
        labels.push(await page.evaluate((index) => $(`.prolink:eq(${index})`).text(), i));
        //console.log(labels[i]);
        await timeout(4000); //safe side//
        await saver(`${process.env.USER_DATA}/monitor/${prefix}${uuid}-${i+1}.png`);
    }
  await browser.close();
  fse.writeFileSync(`${process.env.USER_DATA}/monitor/${prefix}${uuid}.json`,
                JSON.stringify(labels),
                'utf8');
})();