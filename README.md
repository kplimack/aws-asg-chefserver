# aws-asg-chefserver
Scripts to register and unregister a node with a chef-server on provision and terminate.

# Supports
* Debian
* Ubuntu

# Setup
## AMI
Create a debian/ubuntu AMI.  You can make node instantiation faster by running your base recipes on it and doing as much building as appropriate now.  Make sure that this node has the validation key on it so that new nodes can register with the chef-server!  When you're done, make sure to delete /etc/chef/client.pem so that there's no key issues with new nodes.

## AWS IAM
Nodes must be created with an IAM role that contains a policy to allow `ec2:DescribeTags`
* Add a policy to the IAM role for the ASG nodes
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ "ec2:DescribeTags"],
      "Resource": ["*"]
    }
  ]
}
```

## Scripts
* place init.sh and killme.sh in /etc/init.d
* edit init/killme to create hostnames using your schema
I use a schema that is descriptive and enumerable/unique
```
<location>-<role/class>-<instanceID>.[asg.]<tld>
i.e. use1d-worker-i3456d7fdf.asg.face
```
.  I've always been a fan of made up TLDs, as they designate internal connections implicitly.
`hostname="use1d-worker-$(getmeta /meta-data/instance-id).asg.derp"`
```
update-rc.d init.sh start 2
update-rc.d killme.sh stop 0 6
```
* Debian/Ubuntu systems only use run-levels 0, 1, 2, and 6.

# License
Copyright 2014, Jake Plimack Photography, LLC

Licensed under the Apache License, Version 2.0 (the “License”); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
