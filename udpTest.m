port = 25000;
ip = '127.0.0.1';

%socket definition
socket = udp(ip,port);
fopen(socket);

%dummy daten
data = 1:10;

%Versenden der Daten, codiert als double
fwrite(socket,data,'double');

%socket schlieﬂen
fclose(socket);

