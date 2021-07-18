This is a work in progress re-implementation of the Manitoba Immunization Card verification app as a GNU Bash script. Relies on grep, egrep, sed, wget, and zbarcam (zbar-tools) being available.

These are not the best tools for the job. Particularly for parsing JSON and working with the authentication layer.

The official published Android app is 50MB. My use of a bash script, measured in kilobytes is just a goofy code golf exercise to show it can be done this way, and with an output device as simple as a teletype or speaker. It will be the basis of a demo in the form of a immunization verification "machine".

This is product of reverse engineering and does not rely on an officially documented API. As such, incompatible changes are possible without notice.

For now, I have skipped any understanding of the authentication API. To use this app, log into the portal (https://immunizationcard.manitoba.ca/) with your web browser. Enable developer tools and extract a Bearer token from the authorization header. Put the bearer token on a single line in bearertoken.txt . (a trailing newline is fine).

Don't include the header name "authorization:" and the "Bearer" part in bearertoken.txt . You can see in the source code these are already included in our requests. Just include the token itself.

Unfortunately, the bearer tokens only last an hour or two. There also appears to be a refresh token that lasts for 24 hours, but there's no refresh logic to be seen here.... yet.

As such, this is not a practical implementation that you would want to use at a restaurant seating multiple households indoors or any other venue required to check immunization status. Use at your own risk.

Some additional information about the authentication API is in my mailing list post
https://groups.google.com/a/skullspace.ca/g/announce/c/BTF30UKo0I4/m/wOKLxSuqAAAJ

This application reads and processes external inputs: QR codes supplied by other people and JSON data in the government response. This has security implications, see
https://xkcd.com/327/

This implementation has not received a security audit. The choice of GNU Bash poses significant risks, a security bug could result in arbitrary shell commands being run.

An additional reason to say again, use at your own risk.

--------------------

Copyright 2021 Mark Jenkins

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.

You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.