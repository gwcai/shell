#!/bin/bash
/solr_cloud/node1/solr/bin/solr start -cloud -p 8983 -s /solr_cloud/node1/DSSPHOME -z "localhost:2181" -a "-DnumShards=2" -m 8g -force
/solr_cloud/node2/solr/bin/solr start -cloud -p 8984 -s /solr_cloud/node2/DSSPHOME -z "localhost:2181" -a "-DnumShards=2" -m 8g -force
/solr_cloud/node3/solr/bin/solr start -cloud -p 8985 -s /solr_cloud/node3/DSSPHOME -z "localhost:2181" -a "-DnumShards=2" -m 8g -force
