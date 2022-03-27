# Building

```
docker build -t librivox-local .
```

I also changed some files in librivox-ansible:

```diff
diff --git a/deploy.yml b/deploy.yml
index cb53627..f88c53c 100644
--- a/deploy.yml
+++ b/deploy.yml
@@ -1,4 +1,5 @@
 - hosts: server
+  connection: local
   vars_files:
     - versions.yml
   roles:
diff --git a/hosts/localdev/hosts b/hosts/localdev/hosts
index 54ca8fc..f0531c7 100644
--- a/hosts/localdev/hosts
+++ b/hosts/localdev/hosts
@@ -1,2 +1,2 @@
 [server]
-192.168.100.134
+localhost
```
