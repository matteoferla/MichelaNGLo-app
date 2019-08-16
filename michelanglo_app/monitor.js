//required!
const puppeteer = require('puppeteer');
const fs = require('fs');
const uuid = process.argv[2];
const timeout = (ms) => new Promise(resolve => setTimeout(resolve, ms));
//console.log('Loaded');
//console.log(`Checking links for ${uuid}`);

(async () => {
    const browser = process.env.PUPPETEER_CHROME ? await puppeteer.launch({executablePath: process.env.PUPPETEER_CHROME}) : await puppeteer.launch();
    const page = await browser.newPage();
    const url = `http://localhost:8088/data/${uuid}?columns_viewport=6`;
    let labels = ['Initial view'];
    await page.goto(url);
    await page.setViewport({
                          width: 1000,
                          height: 700,
                          deviceScaleFactor: 1,
                        });
    await page.click('body');
    await page.evaluate( () => $('#viewport img').click() ? $('#viewport img').length : undefined );
    await page._client.send('Page.setDownloadBehavior', {behavior: 'allow',
                                                         downloadPath: './michelanglo_app/user-data-monitor/'});
    //await page.evaluate(() => $('.prolink').each());
    await timeout(3000); //safe side//
    const nLinks = await page.evaluate( () => $('.prolink').length );
    const saver = (fn) => NGL.getStage().makeImage({trim: true, antialias: true, transparent: false}).then((blob) => NGL.download(blob, fn));
    await page.evaluate(saver,`${uuid}-0.png`);
    for (let i=0; i < Math.min(nLinks, 100); i++) {
        await page.evaluate((index) => $(`.prolink:eq(${index})`).click(), i);
        labels.push(i + ' → ' +
            await page.evaluate((index) => $(`.prolink:eq(${index})`).text(), i));
        //console.log(labels[i]);
        await timeout(3000); //safe side//
        await page.evaluate(saver, `${uuid}-${i+1}.png`);
    }
  await timeout(3000); //safe side//
  await browser.close();
  fs.writeFile(`./michelanglo_app/user-data-monitor/${uuid}.json`, JSON.stringify(labels), 'utf8', err => undefined);
})();