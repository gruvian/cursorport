# cursorport
GUI Tool that automates both porting of converted cursor images with [win2xcur](https://github.com/quantum5/win2xcur) for Windows to Xcursor format and their installation for usage on Linux. 
### Installation and running
Clone the git repository and check if python3 and prerequisites are installed.
```shell
git clone https://github.com/gruvian/cursorport.git
cd cursorport
python3 main.py
```
### Built in
Python, bash

### Prerequisites
<a href="https://github.com/quantum5/win2xcur">win2xcur</a>

### Troubleshooting
If the cursors are not displaying and defaulting to system default cursor, check
```
cd /usr/share/icons/default
```
And if it exists and it's empty, you can safely remove it. 
Make sure the terminal window in which you're running the script has sudo privileges.


