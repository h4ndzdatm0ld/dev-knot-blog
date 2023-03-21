---
title: "Nornir Netconf 2.0.0 Release"
date: 2023-03-20T00:13:23Z
draft: false
weight: 1
featuredImage: "/images/2023-03/nornir-logo-small.png"
featuredImagePreview: "/images/2023-03/nornir-logo.png"
categories:
  - NetworkAutomation
tags:
  - NetworkAutomation
  - Nornir
  - Netconf
hiddenFromHomePage: false
hiddenFromSearch: false
twemoji: false
lightgallery: true
fontawesome: true
linkToMarkdown: true
rssFullText: false
toc:
  enable: true
  auto: false
code:
  copy: true
  maxShownLines: 50
---
# Introducing Nornir Netconf Plugin v2.0.0

> Improved Maintainability, Enhanced Integration Tests, Data Classes, and CI/CD Integrations

I am excited to announce the release of Nornir NETCONF Plugin version `2.0.0`, a significant update bringing enhanced features and improvements to leverage NETCONF for network automation with the Nornir framework for network devices. This release focuses on improving code quality with the use of a Rust-based linter called 'ruff, enhancing data management by implementing Data Classes, increasing maintainability with standardized integration tests, and exploring advanced CI/CD possibilities. Let's dive into the details of these new features.

## Highlights

- 100 % code coverage
- Multi-Vendor Integration Tests (Nokia, Arista, Cisco[IOSXE,IOSXR])
- No longer leveraging the `sysrepo` container for testing
- ContainerLab based integration tests and local development environment
- Examples documentation updated
- Auto generated documentation has been updated
- Standardized docstrings for proper API documentation generation
- Fully Type-Hinted with MyPy verification in CI/CD
- New task added to `validate` a datastore configuration

## Standardized Integration Tests for Local Development and CI/CD

In order to ensure the maintainability of the Nornir Netconf Plugin, the new release has focused on implementing a standardized format for integration tests for various vendors, including Cisco, Arista, and Nokia. These standardized multi-vendor integration tests are designed to work both during local development using ContainerLab and as part of the CI/CD pipeline.

The tests have been broken into categories. The `common` operations such as retrieving the NETCONF capabilities, locking and unlocking operations, and obtaining the YANG schemas from devices are included into a multi-vendor set of tests that leverage a local Nornir runbook that runs a common set of tests against all the hosts in the runbook. Additionally, vendor-specific tests include `get`, `get_config`, and `edit_config` operations, validating the use of each task type provided by the plugin.

While the CI/CD pipeline runs integration tests against Arista EOS, the full suite of tests runs outside of CI/CD during local development. This is due to a limitation of running ContainerLab topologies on GitHub Runners, which do not have nested virtualization.

## Nested Virtualization and Future CI/CD Possibilities (Concept)

Nested virtualization is a feature that enables a virtual machine (VM) to run within another VM. It allows users to run multiple layers of virtualization, which can be useful for testing and development purposes.

Currently, GitHub Runners do not support nested virtualization. However, there are potential future CI/CD possibilities for network automation CI/CD with Github that could overcome this limitation. One example could be creating a pipeline that leverages a GitHub Action that creates an on-demand/spot bare-metal server in AWS, configure it as a Github Runner and allow it to run the tests. This would enable the execution of the complete test suite within the CI/CD pipeline, ensuring comprehensive validation of the plugin's functionality across various vendors and use cases. This was something that interest me in trying and perhaps I will write a blog post about it in the future and attempt to implement it.

## Structured Data Management with Data Classes

The new release of the Nornir Netconf Plugin has introduced Python Data Classes for response objects, as seen in the `RpcResult` and `SchemaResult` classes in the [Models](https://github.com/h4ndzdatm0ld/nornir_netconf/blob/develop/nornir_netconf/plugins/helpers/models.py) file.

```python
@dataclass
class RpcResult:
    """RPC Reply Result Model."""

    rpc: Optional[RPCReply] = field(default=None, repr=True)
    manager: Optional[Manager] = field(default=None, repr=False)


@dataclass
class SchemaResult:
    """Get Schema Result."""

    directory: str = field(repr=True)
    errors: List[str] = field(repr=False, default_factory=list)
    files: List[str] = field(repr=False, default_factory=list)
```

Data Classes, introduced in Python 3.7, provide a convenient and concise way to define classes that are primarily used to store data. They automatically generate default implementations of common special methods like __init__, __repr__, and __eq__. This allows developers to focus on the data itself and its manipulation, rather than boilerplate code.

By using Data Classes instead of simple strings or basic dictionaries, developers can more easily manage the data returned. In the previous 1.x.x implementation of Nornir Netconf, I attempted to normalize the payload attributes into a common model. However, this added extra complexity without a lot of value and potential for bugs. By using Data Classes, the data is more easily managed and the code is more concise. The users are now in control of the returning RPC object and will have the ability to access the attributes directly as desired.

## The removal of built-in XML to Dict parser

The new release of the plugin offers users greater flexibility and control by removing the built-in XML to Dict parser. This decision reduces code complexity and dependencies, while allowing users to parse the RPC results using their preferred method. Examples of parsing XML payloads to JSON or Python dictionaries using various Python libraries are provided below.

There are several Python libraries available to parse XML, each with their own features and capabilities. Some popular ones include:

- `xml.etree.ElementTree (built-in)`:
A lightweight, efficient library for parsing and creating XML data. It comes built-in with Python and provides an easy-to-use API.
[Documentation](https://docs.python.org/3/library/xml.etree.elementtree.html)

- `lxml`:
A powerful library that combines the simplicity of ElementTree with the speed and features of the libxml2 and libxslt C libraries. It provides support for XPath, XSLT, and validation against XML Schema or DTD.
[Documentation](https://lxml.de/)

- `xml.dom (built-in)`:
This built-in library provides an API for parsing XML using the Document Object Model (DOM). It represents the structure of an XML document as a tree, allowing you to navigate and manipulate the elements.
[Documentation](https://docs.python.org/3/library/xml.dom.html)

- `xml.sax (built-in)`:
A built-in library that supports the Simple API for XML (SAX) for parsing XML. It's a lower-level, event-driven API, which can be more efficient for parsing large XML documents since it doesn't require loading the entire XML tree into memory.
[Documentation](https://docs.python.org/3/library/xml.sax.html)

- `xmltodict`:
A third-party library that allows you to work with XML data as if it were JSON or a Python dictionary. It can simplify the process of parsing XML and converting it to Python data structures.
[Documentation](https://github.com/martinblech/xmltodict)

These are just a few of the many libraries available for parsing XML in Python. The choice of library depends on your specific needs and requirements in terms of ease of use, performance, and additional features. This is why I have chosen to remove the built-in XML to Dict parser from the plugin and allow users to choose the library that best suits their needs.
