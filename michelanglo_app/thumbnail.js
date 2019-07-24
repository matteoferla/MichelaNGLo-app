/*
This nodejs script loads and saves the image to make a thumbnail for twitter & co..
*/

const puppeteer = require('puppeteer');
const uuid = process.argv[2]
const timeout = (ms) => new Promise(resolve => setTimeout(resolve, ms));


process.on('UnhandledPromiseRejectionWarning', err => process.exit(1) ); //this does nothing.

(async () => {
  //for some reason I cannot get npm to install chromium on centos.
  const browser = process.env.PUPPETEER_CHROME ? await puppeteer.launch({executablePath: process.env.PUPPETEER_CHROME}) : await puppeteer.launch();
   //{headless: false} if dev.
  const page = await browser.newPage();
  await page.setViewport({
                          width: 1000,
                          height: 700,
                          deviceScaleFactor: 1,
                        });
  await page.goto(`http://localhost:8088/data/${uuid}?columns_viewport=12`);
  //const errorLogger = (err) =>  console.log("Internal error: " + err.toString());
  //page.on("pageerror", errorLogger);
  //page.on("error", errorLogger);
  await page.click('body');
  await timeout(3000); //safe side.
  await page._client.send('Page.setDownloadBehavior', {behavior: 'allow', downloadPath: './michelanglo_app/user-data/'});
  let blob = await page.evaluate(
				(uuid) => NGL.getStage()
					     .makeImage( {trim: true, antialias: true, transparent: false})
					     .then((blob) => NGL.download(blob, `${uuid}.png`))
				, uuid);
  await timeout(2000);
  await browser.close();
})();



// JUNK!

//const NGL = require('ngl'); cannot run headlessly.
//const fs = require('fs');

  //await page.waitForNavigation({waitUntil: 'domcontentloaded'}); //https://github.com/GoogleChrome/puppeteer/issues/3338
  //const navigationPromise = page.waitForNavigation({ waitUntil: 'load' });


  //await navigationPromise;

/*
  let blob = await page.evaluate( async () => await NGL.getStage().makeImage( {trim: true, antialias: true, transparent: false})
				  )
  console.log(JSON.stringify(blob)); //{}
  await timeout(1000);
  console.log(blob.constructor.name); // "object"   
  //console.log([Blob, Promise].filter((cls) => blob instanceof cls)[0].name) //https://stackoverflow.com/questions/14653349/node-js-can%C2%B4t-create-blobs
  console.log(JSON.stringify(blob)); //{}
   
   //await  fs.writeFile('NGL.png', new Buffer(blob, 'base64'));
*/

/*
  
  //await page.screenshot({path: 'example.png'});
  const blob = await page.evaluate(()=> NGL.getStage().makeImage( {trim: true, antialias: true, transparent: false}));
  console.log(blob);
  console.log(await page.evaluate(()=> NGL.getStage()));
  await  fs.writeFile('NGL.png', new Buffer(blob, 'base64'));
  //console.log(blob);
  await browser.close();
*/

