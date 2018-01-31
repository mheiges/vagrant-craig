
Sandbox for [CraiG](https://github.com/axl-bernal/CraiG) testing.


This requires working with very large BAM files (>60GB) so you'll
probably want the vagrant project directory on an external disk.

Requires at least 4096 GB memory for extractWeightedSignalFilter.pl,
Vagrantfile sets 8192 GB to avoid hitting swap.

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

BAM Index files were not in $CRAIGDATA, so copy those down

```
[17:52 20180130 mheiges@korlan /Volumes/SAVM/Vagrant/vagrant-craig/scratch]
$ rsync -vP $WORKFLOWSERVER:/eupath/data/EuPathDB/workflows/ToxoDB/27/data/tgonME49/gsnap/DBP_Hehl-Grigg/analyze_day3/master/mainresult/results_sorted.bam.bai CRAIG/toxo_data/Hehl/day3_sorted.bai
$ rsync -vP $WORKFLOWSERVER:/eupath/data/EuPathDB/workflows/ToxoDB/27/data/tgonME49/gsnap/DBP_Hehl-Grigg/analyze_day5/master/mainresult/results_sorted.bam.bai CRAIG/toxo_data/Hehl/day5_sorted.bai
$ rsync -vP $WORKFLOWSERVER:/eupath/data/EuPathDB/workflows/ToxoDB/27/data/tgonME49/gsnap/DBP_Hehl-Grigg/analyze_day7/master/mainresult/results_sorted.bam.bai CRAIG/toxo_data/Hehl/day7_sorted.bai
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


## Gotchas

If a helper-script fails it does not necessarily fail the whole craigPreprocess.py
run, at least not until a downstream step hits the missing dependency. e.g.
If regtools fails in the junctions2weightedLocs.py script, the craigPreprocess.py
calling script does not notice. regtools exits with non-zero status; I don't know
offhand how junctions2weightedLocs.py exits.

CraiG leaves state files in place even if a step fails. The next time
CraiG is run it skips the failed step, does not attempt to redo it and
continues on through the pipeline, which fails on the next step that
depends on the failed one. This is why I deleted the `.rnaseq_is_done`,
`.junction.locs`, `.cov` files (and I focused on these files because the
were related to the specific step(s) that I was having the most problem
with at this writing. YMMV.). Deleting all the files in
`hehl_day7.preproc` seems the best way ensure a fully clean run.
