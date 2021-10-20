/*
This nodejs script loads and saves the image to make a thumbnail for twitter & co..
requires PORT and USER_DATA env variables and the uuid to check as argument
*/

process.on('unhandledRejection', up => { throw up });
process.on('UnhandledPromiseRejectionWarning', err => process.exit(1) ); //this does nothing.

const puppeteer = require('puppeteer');
const fse = require('fs-extra');
const timeout = (ms) => new Promise(resolve => setTimeout(resolve, ms));
const uuid = process.argv[2];
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

  await page.goto(`http://localhost:${process.env.PORT}/data/${uuid}?columns_viewport=12`);
  //const errorLogger = (err) =>  console.log("Internal error: " + err.toString());
  //page.on("pageerror", errorLogger);
  //page.on("error", errorLogger);
  await page.click('body');
  await timeout(3000); //safe side.
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
    fse.writeFileSync(`${process.env.USER_DATA}/thumb/${uuid}.png`, file);
  await browser.close();
})();