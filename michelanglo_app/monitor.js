process.on('unhandledRejection', up => { throw up });
//required!
const puppeteer = require('puppeteer');
const fs = require('fs');
const uuid = process.argv[2];
const prefix = process.argv.length === 4 ? process.argv[3] : '';
const timeout = (ms) => new Promise(resolve => setTimeout(resolve, ms));
//console.log('Loaded');
//console.log(`Checking links for ${uuid}`);

(async () => {
    const browser = process.env.PUPPETEER_CHROME ? await puppeteer.launch({executablePath: process.env.PUPPETEER_CHROME}) : await puppeteer.launch();
    const page = await browser.newPage();
    const url = `http://localhost:8088/data/${uuid}?columns_viewport=6`;
    let labels = ['Initial view'];
    await page.goto(url);
    //conf.
    await page.setViewport({
                          width: 1000,
                          height: 700,
                          deviceScaleFactor: 1,
                        });
    await page.click('body');
    await page.evaluate( () => $('#viewport img').click() ? $('#viewport img').length : undefined );
    await page._client.send('Page.setDownloadBehavior', {behavior: 'allow',
                                                         downloadPath: './michelanglo_app/user-data-monitor/'});


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
    // start clicking!
    const nLinks = await page.evaluate( () => $('.prolink').length );
    const saver = (fn) => NGL.getStage().makeImage({trim: true, antialias: true, transparent: false}).then((blob) => NGL.download(blob, fn));
    await page.evaluate(saver,`${prefix}${uuid}-0.png`);
    for (let i=0; i < Math.min(nLinks, 100); i++) {
        await page.evaluate((index) => $(`.prolink:eq(${index})`).click(), i);
        labels.push(await page.evaluate((index) => $(`.prolink:eq(${index})`).text(), i));
        //console.log(labels[i]);
        await timeout(4000); //safe side//
        await page.evaluate(saver, `${prefix}${uuid}-${i+1}.png`);
    }
  await timeout(4000); //safe side//
  await browser.close();
  fs.writeFile(`./michelanglo_app/user-data-monitor/${prefix}${uuid}.json`, JSON.stringify(labels), 'utf8', err => undefined);
})();