# openssl-fips

This repo contains a vanagon based project to build the OpenSSL fips provider, producing a dynamically loadable library `fips.so` (or `fips.dll` on Windows).

OpenSSL 3 introduced a provider architecture for cryptographic operations. OpenSSL supports several [standard providers: `default`, `fips`, etc](https://github.com/openssl/openssl/blob/master/README-PROVIDERS.md). See [OSSL\_PROVIDER-FIPS](https://www.openssl.org/docs/man3.0/man7/OSSL_PROVIDER-FIPS.html) for more information about the `fips` provider.

## FIPS Compliance

### OpenSSL 3.0

Only version **3.0.0** of the `fips` provider is FIPS 140-2 compliant and **certified**. In other words, you cannot build the provider from the latest 3.0.x source! See

* [https://github.com/openssl/openssl/issues/20689](https://github.com/openssl/openssl/issues/20689)
* [https://github.com/openssl/openssl/issues/20800#issuecomment-1517522961](https://github.com/openssl/openssl/issues/20800#issuecomment-1517522961)
* [https://github.com/openssl/openssl/issues/20541#issuecomment-1476989608](https://github.com/openssl/openssl/issues/20541#issuecomment-1476989608)

However, it is recommended to install the **3.0.0** version of the `fips` provider with the latest OpenSSL 3.0.x distribution. Given that constraint, we build the `opennssl-fips` module in this repo, separate for `puppet-runtime`.

### OpenSSL 3.1

[OpenSSL 3.1 was recently released](https://www.openssl.org/blog/blog/2023/03/07/OpenSSL3.1Release/). It introduces a FIPS 140-3 compliant `fips` provider, however, it is not **certified** yet.

There are two notable changes in OpenSSL 3.1 relating to FIPS:

 * The `fips` module performs a self-test every time it's loaded, not once when it's installed.
 * Applications must explicitly request `fips` compatible crypto functions either explicitly in code or in configuration using `default_properties`. See [EVP configuration](https://www.openssl.org/docs/man3.1/man5/config.html#EVP-configuration).

## Encoders & Decoders

The `fips` provider does not implement serialization routines, like reading an RSA key from PEM, as described in section [Using Encoders and Decoders with the FIPS module](https://www.openssl.org/docs/man3.0/man7/fips_module.html#Using-Encoders-and-Decoders-with-the-FIPS-module):

> The built-in OpenSSL encoders and decoders are implemented in both the default and base providers and are not in the FIPS module boundary. However since they are not cryptographic algorithms themselves it is still possible to use them in conjunction with the FIPS module, and therefore these encoders/decoders have the fips=yes property against them. You should ensure that either the default or base provider is loaded into the library context in this case.

Since the agent serializes keys to disk and crypto parameters during TLS, we have to enable `fips` and `default` providers. Additionally, if `fips` is enabled, then `default` must be *explicitly* enabled. See [Default provider and activation](https://www.openssl.org/docs/man3.0/man5/config.html#Default-provider-and-activation):

> If you add a section explicitly activating any other provider(s), you most probably need to explicitly activate the default provider, otherwise it becomes unavailable in openssl. It may make the system remotely unavailable.

## Configuration

OpenSSL supports different ways for an application to use FIPS algorithms. The simpliest, and the one we follow, is to FIPS enable the entire application, see [Making all applications use the FIPS module by default](https://www.openssl.org/docs/man3.0/man7/fips_module.html#Making-all-applications-use-the-FIPS-module-by-default):

> One simple approach is to cause all applications that are using OpenSSL to only use the FIPS module for cryptographic algorithms by default. This approach can be done purely via configuration. ... To do this the default OpenSSL config file will have to be modified.

## Installation

As described in the [Appendix A of the OpenSSL FIPS 140-2 Security Policy](https://csrc.nist.gov/CSRC/media/projects/cryptographic-module-validation-program/documents/security-policies/140sp4282.pdf):

> The Module shall have the self-tests run, and the Module config file output generated on each platform where it is intended to be used. The Module config file output data shall not be copied from one machine to another.

Therefore, we have to use a post install action to install the `fips.so` shared library, run the self-tests, generate the `fipsmodule.cnf` configuration file and enable the `fips` provider via configuration in the main `openssl.cnf`.
