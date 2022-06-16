#!/usr/bin/env bash

ssh root@oci-node-1.glob.k8s.rapgru.com "rm -rf /boot/kernels/*"
ssh root@oci-node-2.glob.k8s.rapgru.com "rm -rf /boot/kernels/*"
ssh root@oci-node-3.glob.k8s.rapgru.com "rm -rf /boot/kernels/*"
ssh root@oci-node-4.glob.k8s.rapgru.com "rm -rf /boot/kernels/*"