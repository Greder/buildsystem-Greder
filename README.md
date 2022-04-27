<h1 align="center">How to build image Neutrino-HD2 (mohousch)</h1>
<h1 align="center">for hl101:</h1>

![](https://github.com/mohousch/neutrinohd2/blob/master/nhd2-exp/doc/resources/mainmenu.png)

![](https://github.com/mohousch/neutrinohd2/blob/master/nhd2-exp/doc/resources/channellist.png)

![](https://github.com/mohousch/neutrinohd2/blob/master/nhd2-exp/doc/resources/infoviewer.bmp)

![](https://github.com/mohousch/neutrinohd2/blob/master/nhd2-exp/doc/resources/metrixhd.png)

**git clone:**
```bash
git clone https://github.com/Greder/buildsystem-hd2.git
```
**cd:**
```bash
cd buildsystem-hd2
```
**for first use:**
```bash
sudo ./prepare-for-bs.sh
```
**machine configuration only HL101:**
```bash
make init
```
**build image:**
```bash
make release-neutrino
```

**for more details:**
```bash
make help
```

**supported boards:**
```bash
make print-boards
```
