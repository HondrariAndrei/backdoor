<h1>Backdoor</h1>

<h2> Author</h2>
Karl Castillo<br />
karl@karlworks.com

<h2>Dependencies</h2>

* libpcap
* libpcap-devel
* ruby
* ruby-devel
* pcaprub
* packetfu

<h2>Server</h2>
* Config file (CSV):
 * interface,client destination port,server destination port,delay

      <b>interface</b> - the device where the packets will be going and coming from<br />
      <b>client destination port</b> - the port that the client packets will be going to<br />
      <b>server destination port</b> - the port that the server packets will be going to<br />
      <b>delay</b> - the amount of delay in between the packet transfer (seconds)<br />

 * Running:

      ```ruby <name of the server file>```

<h2>Client</h2>
* Arguments:

  <b>--host, -H</b>: the IP address of the victim machine<br />
  <b>--sport, -s</b>: the destination port of packets going to the server<br />
  <b>--dport, -d</b>: the destination port of packets coming form the server<br />
  <b>--interface, -i</b>: the device where the packets will be going and coming from<br />
  <b>--delay, -y</b>: the delay between each packet transfer (seconds)
	
* Running:
	
	```ruby <name of the client file> <options>```
	
[![endorse](http://api.coderwall.com/koralarts/endorsecount.png)](http://coderwall.com/koralarts)