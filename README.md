# RTT-ReverseTlsTunnel تانل معکوس
سیستم عامل پیشنهادی : ubuntu 22

بهترین روش تونل کردن دو تا سرور ایران و خارج همین روش Reverse Tls Tunnel هستش که خیلی ها الان با مفهموش آشنا هستید .

در این روش شما میتونید از پرتوکل های مختلف استفاده کنید. 

کاری که من کردم این بود که مراحلی که برای نصب دستی انجام میدادم رو آوردم توی اسکریپت تا هم نصب راحتتری داشته باشید هم براش سرویس نوشته بشه تا اگر سرور ریستارت شد یا هر اتفاقی دیکه افتاد ارتباط تانل مجدد برقرار بشه 

برای نصب دسترسی روت حتما نیاز است . اگر یوزری بجز روت دارید تایپ کنید sudo -i

یک سرور ایران رو میتونید به چند سرور خارج متصل کنید و حتی برعکس



## Install 

Easy installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/armanibash/RTT-ReverseTlsTunnel/main/install.sh)
```

### How to Manage مدیریت سرویس
Stop the service.
```bash
systemctl stop tunnel.service
```
View the status of the service.
```bash
systemctl status tunnel.service
```
Restart the service.
```bash
systemctl restart tunnel.service
```

## Related

Thanks to

https://github.com/radkesvat/ReverseTlsTunnel/tree/master توسعه دهنده 

https://github.com/azadrahorg/RTT-Tunnel-Helper/tree/main 
