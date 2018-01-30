
Sandbox for [CraiG](https://github.com/axl-bernal/CraiG) testing.


This requires working with very large BAM files (>60GB) so you'll
probably want the vagrant project directory on an external disk.

Testing as of 1/2018. Expect these instructions to rapidly
become out of date (esp. the sample data sources).

Copy test data

```
WORKFLOWSERVER=???
CRAIGDATA=/home/???/CRAIG

[11:41 20180130 /Volumes/SAVM/Vagrant/vagrant-craig/scratch]
$ rsync -aPv -L --exclude craig.simg  --exclude CraiG-master.zip --exclude CraiG-master  \
  $WORKFLOWSERVER:$CRAIGDATA .
```

Remove broken symlinks that were copied from data source.

```
[13:02 20180130 mheiges@korlan /Volumes/SAVM/Vagrant/vagrant-craig/scratch]
$ find CRAIG/ -type l  | xargs rm
```

Symlink data on scratch into vagrant home.

```
[vagrant@localhost ~]$ ln -nsf /vagrant/scratch/CRAIG
```

Patch paths in configs (**set `???` to correct value**)

```
[vagrant@localhost ~]$ find CRAIG -follow -type f -name '*conf' | xargs perl -pi -e 's/???/vagrant/g'
```


```
rm /home/vagrant/CRAIG/toxo_data/Hehl/hehl_day7.preproc/tgondii-rna.hehl.day7.chr.rnaseq_is_done
rm /home/vagrant/CRAIG/toxo_data/Hehl/hehl_day7.preproc/tgondii-rna.hehl.day7.chr.junction.locs
rm /home/vagrant/CRAIG/toxo_data/Hehl/hehl_day7.preproc/tgondii-rna.hehl.day7.chr.cov
```

```
craigPreprocess.py -v   --pre-config /home/vagrant/CRAIG/toxo_data/Hehl/hehl_day7.preconf   --out-dir /home/vagrant/CRAIG/toxo_data/Hehl/hehl_day7.preproc   --annot-fmt gtf --transcript-tag exon --cds-tag CDS tgondii   /home/vagrant/CRAIG/toxo_data/fromAxel/tgonME49.gtf   /home/vagrant/CRAIG/toxo_data/fromAxel/topLevelGenomicSeqs.fa   --gc-classes=100 --model ngscraig --config config
```