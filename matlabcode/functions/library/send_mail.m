function send_mail(mail_receive,mail_text)

setpref('Internet', 'E_mail', 'hoelzl.josef@gmail.com');
setpref('Internet', 'SMTP_Username', 'hoelzl.josef@gmail.com');
setpref('Internet', 'SMTP_Password', 'rcv9m6h3');
setpref('Internet', 'SMTP_Server', 'smtp.gmail.com');
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port', '465');

sendmail(mail_receive,mail_text);

end