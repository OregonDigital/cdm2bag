ContentDM to BagIt
==================

**cdm2bag** is a Ruby script that facilitated the bulk migration of collections into Oregon Digital. Now that our migration is completed, future work will happen with **csv2bag**: http://github.com/OregonDigital/csv2bag

cdm2bag will accept 1 or more desc.all files from a collection in CONTENTdm.
This file is parsed, the fields are mapped to output predicates, high resolution images/media are located and matched where appropriate, and everything is output to Bags. Optional mapping methods can perform data cleanup on each field, as well as lookups for linked open data URIs from several sources.

Compound objeects are supported, the compound object XML (CPD) file is retrieved and parsed. Child objects are handled like normal objects, and the compound objects are shuffled to the end and created last.

LOD lookups are cached in YML files, and these can be checked for accuracy and edited for later use.
