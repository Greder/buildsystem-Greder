<h1 align="center">How to build image Neutrino-HD2 (mohousch)</h1>
<h1 align="center">for hl101:</h1>

![](https://github.com/Greder/doc/blob/main/screenshot1.png)

![](https://github.com/Greder/doc/blob/main/screenshot4.png)

![](https://github.com/Greder/doc/blob/main/screenshot5.png)

![](https://github.com/Greder/doc/blob/main/screenshot2.png)

**git clone:**
```bash
git clone https://github.com/Greder/buildsystem.git
```
**cd:**
```bash
cd buildsystem
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
