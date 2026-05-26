<p align="center"><img width=600 alt="EvilnoVNC" src="https://github.com/Hann1bl3L3ct3r/EvilnoVNC/blob/main/EvilnoVNC.png"></p>

# EvilnoVNC
**EvilnoVNC** is a Ready to go Phishing Platform. 

Unlike other phishing techniques, EvilnoVNC allows 2FA bypassing by using a real browser over a noVNC connection.

In addition, this tool allows us to see in real time all of the victim's actions, access to their downloaded files and the entire browser profile, including cookies, saved passwords, browsing history and much more.


# Requirements
- Docker
- Chromium


# Download
It's recommended to clone the complete repository or download the zip file.\
Additionally, it's necessary to build Docker manually. You can do this by running the following commands:
```
git clone https://github.com/Hann1bl3L3ct3r/EvilnoVNC
cd EvilnoVNC ; sudo chown -R 103 Downloads
sudo docker build -t hann1bl3l3ct3r/evilnovnc .
```


# Usage
```
./start.sh -h
                                                     
  _____       _ _          __     ___   _  ____
 | ____|_   _(_) |_ __   __\ \   / / \ | |/ ___|
 |  _| \ \ / / | | '_ \ / _ \ \ / /|  \| | |
 | |___ \ V /| | | | | | (_) \ V / | |\  | |___
 |_____| \_/ |_|_|_| |_|\___/ \_/  |_| \_|\____|

  ---------------- by @JoelGMSec --------------

Usage:  ./start.sh $resolution $url [--ssl-cert PATH --ssl-key PATH]

Examples (HTTP on :80, default):
        1280x720  16bits: ./start.sh 1280x720x16 http://example.com
        1280x720  24bits: ./start.sh 1280x720x24 http://example.com
        1920x1080 16bits: ./start.sh 1920x1080x16 http://example.com
        1920x1080 24bits: ./start.sh 1920x1080x24 http://example.com

Dynamic resolution:
        ./start.sh dynamic http://example.com

HTTPS on :443 (optional):
        ./start.sh dynamic http://example.com --ssl-cert ./certs/fullchain.pem --ssl-key ./certs/privkey.pem

```

### HTTPS / TLS

When `--ssl-cert` and `--ssl-key` are supplied, EvilnoVNC listens on TCP/443 with TLS instead of TCP/80
plaintext. Both flags must be passed together. Paths must point to PEM-encoded files on the host; they
are bind-mounted read-only into the container. noVNC's client picks up `wss://` automatically once the
landing page is served over HTTPS, so no frontend changes are required.

```
sudo ./start.sh dynamic http://example.com \
  --ssl-cert /etc/letsencrypt/live/phish.example.org/fullchain.pem \
  --ssl-key  /etc/letsencrypt/live/phish.example.org/privkey.pem
```


# Features & To Do
- [X] Export Evil-Chromium profile to host
- [X] Save download files on host
- [X] Disable parameters in URL (like password)
- [X] Disable key combinations (like Alt+1 or Ctrl+S)
- [X] Disable access to Thunar
- [X] Decrypt cookies in real time
- [X] Expand cookie life to 99999999999999999
- [X] Dynamic title from original website
- [X] Dynamic resolution from preload page
- [X] Basic keylogger
- [X] Replicate real user-agent and other stuff
- [X] Faster than ever
- [ ] Crazy new ideas


# License
This project is licensed under the GNU 3.0 license - see the LICENSE file for more details.


# Credits and Acknowledgments
Original idea by [@mrd0x](https://twitter.com/mrd0x): https://mrd0x.com/bypass-2fa-using-novnc \
This tool has been created and designed from scratch by Joel Gámez Molina // @JoelGMSec

Special thanks to [@ms101](https://github.com/ms101) for some fixes and improvements. \
Special thanks to [@git-it](https://github.com/git-it) for User-agent and Accept-Language patch.


# Disclaimer
This software does not offer any kind of guarantee. Its use is exclusive for educational environments and / or security audits with the corresponding consent of the client. The fork maintainer is not responsible for its misuse or for any possible damage caused by it.
