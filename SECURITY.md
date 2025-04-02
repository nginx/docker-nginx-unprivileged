# Security Policy

## Latest Versions

We advise users to run or update to the most recent release of the NGINX Docker unprivileged image. Older versions of the NGINX Docker unprivileged image may not have all enhancements and/or bug fixes applied to them.

## Reporting a Vulnerability

The F5 Security Incident Response Team (F5 SIRT) offers two methods to easily report potential security vulnerabilities:

- If you’re an F5 customer with an active support contract, please contact [F5 Technical Support](https://www.f5.com/support).
- If you aren’t an F5 customer, please report any potential or current instances of security vulnerabilities in any F5 product to the F5 Security Incident Response Team at <f5sirt@f5.com>.

For more information, please read the F5 SIRT vulnerability reporting guidelines available at [https://www.f5.com/support/report-a-vulnerability](https://www.f5.com/support/report-a-vulnerability).

## CVEs to be considered

If you find a security vulnerability that directly affects a direct NGINX library dependency we encourage you open an issue detailing the security vulnerability. ***Only vulnerabilities related to to direct NGINX library dependencies will be considered. Other security vulnerabilities will be addressed by the weekly Monday night build and as such will be ignored/promptly closed.***

For reference, the direct NGINX library dependencies are:

- For Debian:
  - `libc6`
  - `libcrypt1`
  - `libpcre2`
  - `libssl`
  - `zlib1g`

- For Alpine Linux:
  - `libc`
  - `libcrypto`
  - `libpcre2`
  - `libssl`
  - `libz`
