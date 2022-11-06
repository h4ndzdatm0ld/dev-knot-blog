---
title: Ansible - Generate a Dynamic Inventory at Runtime
author: Hugo Tinoco
type: post
draft: false
date: 2019-01-14T04:02:54+00:00
url: /2019/01/14/site-to-site-ipsec-over-mpls-vpn/
timeline_notification:
  - 1547438717
categories:
  - Networking
  - Ansible
  - DevOps
  - Network Automation
---

We don't always get lucky enough to have a dynamic inventory from a trusted source of truth/record. Hell, sometimes we don't even have a static inventory accessible for our playbooks to use. Oh, but that's right! That team, under that BU has a spreadsheet with {X} part of the network. Maybe we can use that? Well, I'm not here to write about which problem to tackle first, but how you can leverage `ansible.builtin.add_hosts` and `json_schema` to rely on data from the user to dynamically create an inventory in memory.

As Network Automation Engineers, we commonly find ourselves helping everyone and anyone across the organization to alleviate those repetitive patterns. As we continue to evolve and adapt, we must determine what is worth the effort. Can we automate this specific task, without a dynamic inventory? Sure, we can find ways around that. One thing we already know, is never to trust the input from any user. Now, how to take these two things and create a strategy that's repeatable and able to provide a `dynamic` feel to our inventories?

Scenario:

A new request comes into the team. A user would like to provide you with a list of devices and extract some information from them and then decide if some action should happen or not. Simple request, right? So, what do you do with this list of devices? Surely, we won't be creating new static inventory every time and updating our repository with a new and updated YAML file every time with the correct hosts, attached to the Change Request.

It's good to take a moment and understand where this data will come from. Does your environment run Ansible Automation Platform/Tower/Awx? Will it be executed from an API? Lets say for the sake of the blog-post, this will be ran from AWX and the data provided by the user will be passed into your playbook as `extra-vars`.

Going back to the user provided data; a list of dictionaries with device information such as the hostname. For example,

```yaml
[
  { "hostname": "some-hostname-0.kewl-corp.com", "check-this": "some expected value" },
  { "hostname": "some-hostname-1.kewl-corp.com", "check-this": "some expected value" },
  { "hostname": "some-hostname-2.kewl-corp.com", "check-this": "some expected value" },
]
```

Okay, well - we have our user expected variable. We've communicated this with the `customer` and they have agreed. They can provide this information when they need to use our awesome automation and provide this as part of the payload.

The goal will be to dynamically create an inventory group called `devices` from this user input. We will orchestrate our playbook and use the import playbook strategy from a higher level playbook.

```bash
- pb.orchestration-layer.yml
  - imports -> pb.validate-create-inv.yml
  - imports -> pb.some-network-automation.yml
```

Where does `JSON schema` come into the mix? Well, we have to ensure the data from the user is correct! Remember, that Jira story that had the acceptance criteria which was to ensure the customer was aware of the user input format? Yeah, lets actually enforce it.

Copy the user input example above and simply generate a JSON schema using any available generation tool online. Lets take the most basic example:

```json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "array",
  "items": [
    {
      "type": "object",
      "properties": {
        "hostname": {
          "type": "string"
        },
        "check-this": {
          "type": "string"
        }
      },
      "required": ["hostname", "check-this"]
    },
    {
      "type": "object",
      "properties": {
        "hostname": {
          "type": "string"
        },
        "check-this": {
          "type": "string"
        }
      },
      "required": ["hostname", "check-this"]
    },
    {
      "type": "object",
      "properties": {
        "hostname": {
          "type": "string"
        },
        "check-this": {
          "type": "string"
        }
      },
      "required": ["hostname", "check-this"]
    }
  ]
}
```

Save the file locally within your playbook directory. We need to know the exact path to this Schema while we run the validation.

```bash
schemas/user-input.json
```

We'll create a `tasks` folder and a new YAML file within called `validate-user-input.yml` - the contents will be as followed

````yaml
---
- name: "DEFINE SCHEMA PATH"
  ansible.builtin.set_fact:
    validating_schema: "{{ lookup('ansible.builtin.file', './schemas/user-input.json')}}"
    user_input: "{{ user_input | to_json }}"

- name: "VALIDATE USER DATA AGAINST JSON SCHEMA"
  ansible.builtin.set_fact:
    schema_check: "{{ lookup('ansible.utils.validate', user_input, validating_schema, engine='ansible.utils.jsonschema' }}"

```yaml
---
- name: "VALIDATE AND CREATE INVENTORY"
  hosts: "localhost"
  gather_facts: false
  tasks:
    - name: "VALIDATE USER INPUT WITH JSON SCHEMA"
````
