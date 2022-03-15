#!/bin/bash
# Set some default values:
pheno_name="y"
ext=""
n_cores=1
do_clump_pop1=1
do_est_beta_pop1=1
do_predict_pop1=1
do_est_beta_pop1_precision=1
do_est_beta_InformPrior=1
do_predict_pop2_stage2=1
do_clump_pop2=1
do_est_beta_pop2=1
do_predict_pop2=1
do_combine=1
by_chr=0
by_chr_sumstats=0
indir=0
pop1="pop1"
pop2="pop2"
thinned_snplist=0
n_max_locus=0
ld_shrink=0
recomb_pop1_file=0
recomb_pop2_file=0
N_pop1=10000
N_pop2=10000
ids_col=TRUE
ranking=f.stat
pop1_valid_data=0
pop2_valid_data=0
strand_check=0
cov_names="000"

usage()
{
  echo "Usage: ridgePRS [ -n | --n_cores n_cores ] [ -b | --bfile bfile ]
                        [ -o | --outdir outdir ] 
                        [ -v | --eur_ld_ids eur_ld_ids ] filename(s)"
  exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n ridgePRS -o b:o:n:c:d:e:f:g:h:i:j:k:l:m:p:q:r:s:t:u:v:w:x:y:z:1:2:3:4:5:6:7: --long bfile:,outdir:,n_cores:,pop1_ld_ids:,pop2_ld_ids:,pop1_ld_bfile:,pop2_ld_bfile:,pop1_sumstats:,pop2_sumstats:,pop1_valid_data:,pop2_valid_data:,pop1_test_data:,pop2_test_data:,pop1_bfile:,pop2_bfile:,pop1_qc_snplist:,pop2_qc_snplist:,do_clump_pop1:,do_est_beta_pop1:,do_predict_pop1:,do_est_beta_pop1_precision:,do_est_beta_InformPrior:,do_predict_pop2_stage2:,do_clump_pop2:,do_est_beta_pop2:,do_est_beta_pop2:,do_predict_pop2:,do_combine:,by_chr:,cov_names:,pheno_name:,indir:,by_chr_sumstats:,pop2:,thinned_snplist:,n_max_locus:,recomb_pop1_file:,recomb_pop2_file:,N_pop1:,N_pop2:,ranking:,ld_shrink:,pop1:,ids_col:,sumstats_snpID:,sumstats_beta:,sumstats_allele1:,sumstats_allele0:,sumstats_p:,sumstats_n:,sumstats_se:,sumstats_frq:,strand_check: -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

#echo "PARSED_ARGUMENTS is $PARSED_ARGUMENTS"
eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -b | --bfile)   bfile="$2" ; shift 2 ;;
    -o | --outdir) outdir="$2" ; shift 2 ;;
    -n | --n_cores) n_cores="$2" ; shift 2 ;;
    -c | --pop1_ld_ids) pop1_ld_ids="$2" ; shift 2 ;;
    -d | --pop2_ld_ids) pop2_ld_ids="$2" ; shift 2 ;;
    --pop1_ld_bfile) pop1_ld_bfile="$2" ; shift 2 ;;
    --pop2_ld_bfile) pop2_ld_bfile="$2" ; shift 2 ;;
    -e | --pop1_sumstats)   pop1_sumstats="$2" ; shift 2  ;;
    -f | --pop2_sumstats)   pop2_sumstats="$2"   ; shift 2  ;;
    -g | --pop1_valid_data) pop1_valid_data="$2" ; shift 2 ;;
    -h | --pop2_valid_data) pop2_valid_data="$2" ; shift 2 ;;
    -i | --pop1_test_data) pop1_test_data="$2" ; shift 2 ;;
    -j | --pop2_test_data) pop2_test_data="$2" ; shift 2 ;;
    --pop1_bfile) pop1_bfile="$2" ; shift 2 ;;
    --pop2_bfile) pop2_bfile="$2" ; shift 2 ;;
    -k | --pop1_qc_snplist) pop1_qc_snplist="$2" ; shift 2 ;;
    -l | --pop2_qc_snplist) pop2_qc_snplist="$2" ; shift 2 ;;
    -m | --do_clump_pop1) do_clump_pop1="$2" ; shift 2 ;;
    -p | --do_est_beta_pop1) do_est_beta_pop1="$2" ; shift 2 ;;
    -q | --do_predict_pop1) do_predict_pop1="$2" ; shift 2 ;;
    -r | --do_est_beta_pop1_precision) do_est_beta_pop1_precision="$2" ; shift 2 ;;
    -s | --do_est_beta_InformPrior) do_est_beta_InformPrior="$2" ; shift 2 ;;
    -t | --do_predict_pop2_stage2) do_predict_pop2_stage2="$2" ; shift 2 ;;
    -v | --do_clump_pop2) do_clump_pop2="$2" ; shift 2 ;;
    -w | --do_est_beta_pop2) do_est_beta_pop2="$2" ; shift 2 ;;
    -x | --do_predict_pop2) do_predict_pop2="$2" ; shift 2 ;;
    -y | --do_combine) do_combine="$2" ; shift 2 ;;
    -z | --by_chr) by_chr=$2 ; shift 2 ;;
    -1 | --cov_names) cov_names=$2 ; shift 2 ;;
    -2 | --pheno_name) pheno_name=$2 ; shift 2 ;;
    -3 | --indir) indir=$2 ; shift 2 ;;
    -4 | --by_chr_sumstats) by_chr_sumstats=$2 ; shift 2 ;;
    --pop1) pop1=$2 ; shift 2 ;;
    -5 | --pop2) pop2=$2 ; shift 2 ;;
    -6 | --thinned_snplist) thinned_snplist=$2 ; shift 2 ;;
    -7 | --n_max_locus) n_max_locus=$2 ; shift 2 ;;
    -8 | --recomb_pop1_file) recomb_pop1_file=$2 ; shift 2 ;;
    -9 | --recomb_pop2_file) recomb_pop2_file=$2 ; shift 2 ;;
    -0 | --N_pop1) N_pop1=$2 ; shift 2 ;;
    -a | --N_pop2) N_pop2=$2 ; shift 2 ;;
    --ranking) ranking=$2 ; shift 2 ;;
    --ld_shrink) ld_shrink=$2 ; shift 2 ;;
    --ids_col) ids_col=$2 ; shift 2 ;;
    --sumstats_p) sumstats_p=$2 ; shift 2 ;;
    --sumstats_snpID) sumstats_snpID=$2 ; shift 2 ;;
    --sumstats_beta) sumstats_beta=$2 ; shift 2 ;;
    --sumstats_allele1) sumstats_allele1=$2 ; shift 2 ;;
    --sumstats_allele0) sumstats_allele0=$2 ; shift 2 ;;
    --sumstats_n) sumstats_n=$2 ; shift 2 ;;
    --sumstats_se) sumstats_se=$2 ; shift 2 ;;
    --sumstats_frq) sumstats_frq=$2 ; shift 2 ;;
    --strand_check) strand_check=$2 ; shift 2 ;;
    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;
    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGUMENTS when getopt was called...
    *) echo "Unexpected option: $1 - this should not happen."
       usage ;;
  esac
done

if [ $indir = 0 ]
then
    indir=$outdir
fi

echo "Options in effect:"
echo "outdir  : $outdir"
echo "bfile   : $bfile"
echo "n_cores : $n_cores"
echo "pop1_ld_ids : $pop1_ld_ids"
echo "pop2_ld_ids : $pop2_ld_ids"
echo "pop1_sumstats : $pop1_sumstats"
echo "pop2_sumstats : $pop2_sumstats"
echo "pop1_valid_ids : $pop1_valid_ids"
echo "pop2_valid_ids : $pop2_valid_ids"
echo "pop1_test_ids : $pop1_test_ids"
echo "pop2_test_ids : $pop2_test_ids"
echo "outdir : $outdir"
echo "pop1_qc_snplist : $pop1_qc_snplist"
echo "pop2_qc_snplist : $pop2_qc_snplist"
echo "do_clump_pop1 : $do_clump_pop1"
echo "do_est_beta_pop1 : $do_est_beta_pop1"
echo "do_predict_pop1 : $do_predict_pop1"
echo "do_est_beta_pop1_precision : $do_est_beta_pop1_precision"
echo "do_est_beta_InformPrior : $do_est_beta_InformPrior"
echo "do_predict_pop2_stage2 : $do_predict_pop2_stage2"
echo "do_clump_pop2 : $do_clump_pop2"
echo "do_est_beta_pop2 : $do_est_beta_pop2"
echo "do_predict_pop2 : $do_predict_pop2"
echo "do_combine : $do_combine"
echo "by_chr : $by_chr"
echo "by_chr_sumstats : $by_chr_sumstats"
echo "pheno_name : $pheno_name"
echo "cov_names : $cov_names"
echo "indir : $indir"
echo "pop1 : $pop1"
echo "pop2 : $pop2"
echo "n_max_locus : $n_max_locus"
echo "thinned_snplist : $thinned_snplist"
echo "recomb_pop1_file : $recomb_pop1_file"
echo "recomb_pop2_file : $recomb_pop2_file"
echo "N_pop1 : $N_pop1"
echo "N_pop2 : $N_pop2"
echo "ranking : $ranking"
echo "ld_shrink : $ld_shrink"
echo "ids_col : $ids_col"
echo "strand_check : $strand_check"
echo ""

mkdir $outdir
mkdir $outdir/clump
mkdir $outdir/models
mkdir $outdir/models/lambda

if [ $ranking != "pv" ] && [ $ranking != "f.stat" ] && [ $ranking != "thinned.f.stat" ]
then
    echo "Invalid argument, ranking="$ranking
    exit
fi

if [ $indir == "" ]
then
    indir=$outdir
fi

if [ $do_clump_pop1 -eq 1 ]
then
    for chr in {1..22}
    do
	bfile1=$pop1_ld_bfile
	if [ $by_chr -eq 1 ]
	then
	    bfile1=$pop1_ld_bfile$chr
	fi
	pop1_sumstats1=$pop1_sumstats
	if [ $by_chr_sumstats != 0 ]
	then
	    pop1_sumstats1=$pop1_sumstats$chr$by_chr_sumstats
	fi
	plink --bfile $bfile1 \
	      --chr $chr \
	      --clump $pop1_sumstats1 \
	      --clump-field $sumstats_p --clump-snp-field $sumstats_snpID \
	      --clump-p1 1e-1 --clump-p2 1e-1 --clump-kb 1000 --clump-r2 0.01 \
	      --keep $pop1_ld_ids \
	      --extract $pop1_qc_snplist \
	      --out $outdir/clump/$pop1\_$chr
	rm $outdir/clump/$pop1\_$chr.clumped.gz
	gzip $outdir/clump/$pop1\_$chr.clumped
    done
fi

if [ $do_est_beta_pop1 -eq 1  ]
then
    rm $outdir/models/$pop1*
    Rscript --vanilla ~/BridgePRS/bin/est_beta_bychr.R \
	    --clump.stem $indir/clump/$pop1 \
	    --sumstats $pop1_sumstats \
	    --thinned.snplist $thinned_snplist \
	    --n.max.locus $n_max_locus \
	    --ld.ids $pop1_ld_ids \
	    --beta.stem $outdir/models/$pop1 \
	    --bfile $pop1_ld_bfile \
	    --precision FALSE \
	    --lambda 0.05,0.1,0.2,0.5,1,2,5 \
	    --S 0,0.25,0.5,0.75,1 \
	    --sumstats.snpID $sumstats_snpID \
	    --sumstats.betaID $sumstats_beta \
	    --sumstats.allele1ID $sumstats_allele1 \
	    --sumstats.allele0ID $sumstats_allele0 \
	    --sumstats.nID $sumstats_n \
	    --sumstats.seID $sumstats_se \
	    --sumstats.frqID $sumstats_frq \
	    --n.cores $n_cores \
	    --by.chr $by_chr \
	    --by.chr.sumstats $by_chr_sumstats \
	    --recomb.file $recomb_pop1_file \
	    --ld.shrink $ld_shrink \
	    --strand.check $strand_check \
	    --Ne $N_pop1
fi

if [ $do_predict_pop1 -eq 1  ]
then
    rm $outdir/$pop1\_stage1*
    Rscript --vanilla ~/BridgePRS/bin/predict_bychr.R \
	    --beta.stem $outdir/models/$pop1 \
	    --out.file  $outdir/$pop1\_stage1 \
	    --p.thresh  1e-1,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7,1e-8 \
	    --non.overlapping FALSE \
	    --bfile $pop1_bfile \
	    --test.data $pop1_test_data \
	    --valid.data $pop1_valid_data \
	    --n.cores $n_cores \
	    --cov.names $cov_names \
	    --pheno.name $pheno_name \
	    --ranking pv \
	    --strand.check $strand_check \
	    --by.chr $by_chr
fi

if [ $do_est_beta_pop1_precision -eq 1  ]
then
    rm $outdir/models/stage1*
    rm $outdir/models/lambda/rs*.gz
    Rscript --vanilla ~/BridgePRS/bin/est_beta_bychr.R \
	    --clump.stem $indir/clump/$pop1 \
	    --sumstats $pop1_sumstats \
	    --thinned.snplist $thinned_snplist \
	    --n.max.locus $n_max_locus \
	    --ld.ids $pop1_ld_ids \
	    --bfile $pop1_ld_bfile \
	    --beta.stem $outdir/models/stage1 \
	    --param.file $outdir/$pop1\_stage1_best_model_params.dat \
	    --precision TRUE \
	    --sumstats.snpID $sumstats_snpID \
	    --sumstats.betaID $sumstats_beta \
	    --sumstats.allele1ID $sumstats_allele1 \
	    --sumstats.allele0ID $sumstats_allele0 \
	    --sumstats.nID $sumstats_n \
	    --sumstats.seID $sumstats_se \
	    --sumstats.frqID $sumstats_frq \
	    --n.cores $n_cores \
	    --by.chr.sumstats $by_chr_sumstats \
	    --recomb.file $recomb_pop1_file \
	    --ld.shrink $ld_shrink \
	    --Ne $N_pop1 \
	    --strand.check $strand_check \
	    --by.chr $by_chr
fi

if [ $do_est_beta_InformPrior -eq 1  ]
then
    rm $outdir/models/$pop2\_stage2*
    Rscript --vanilla ~/BridgePRS/bin/est_beta_InformPrior_bychr.R \
	    --sumstats  $pop2_sumstats \
	    --ld.ids $pop2_ld_ids \
	    --prior $outdir/models/stage1 \
	    --param.file $outdir/$pop1\_stage1_best_model_params.dat \
	    --beta.stem $outdir/models/$pop2\_stage2 \
	    --bfile $pop2_ld_bfile \
	    --w.prior 1,2,5,10,15,20,50,100,200,500 \
	    --sumstats.snpID $sumstats_snpID \
	    --sumstats.betaID $sumstats_beta \
	    --sumstats.allele1ID $sumstats_allele1 \
	    --sumstats.allele0ID $sumstats_allele0 \
	    --sumstats.nID $sumstats_n \
	    --sumstats.seID $sumstats_se \
	    --sumstats.frqID $sumstats_frq \
	    --precision 0 \
	    --n.cores $n_cores \
	    --recomb.file $recomb_pop2_file \
	    --Ne $N_pop2 \
	    --by.chr.sumstats $by_chr_sumstats \
	    --ranking $ranking \
	    --ld.shrink $ld_shrink \
	    --strand.check $strand_check \
	    --by.chr $by_chr
fi

if [ $do_predict_pop2_stage2 -eq 1  ]
then
    rm $outdir/$pop2\_stage2*
    Rscript --vanilla ~/BridgePRS/bin/predict_bychr.R \
	    --beta.stem $outdir/models/$pop2\_stage2 \
	    --out.file $outdir/$pop2\_stage2 \
	    --p.thresh 1e-1,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7,1e-8 \
	    --bfile $pop2_bfile \
	    --test.data $pop2_test_data \
	    --valid.data $pop2_valid_data \
	    --n.cores $n_cores \
	    --cov.names $cov_names \
	    --pheno.name $pheno_name \
	    --all.preds TRUE \
	    --ranking $ranking \
	    --strand.check $strand_check \
	    --by.chr $by_chr
fi

if [ $do_clump_pop2 -eq 1  ]
then
    for chr in {1..22}
    do
	bfile1=$pop2_ld_bfile
	if [ $by_chr -eq 1 ]
	then
	    bfile1=$pop2_ld_bfile$chr
	fi
	pop2_sumstats1=$pop2_sumstats
	if [ $by_chr_sumstats != 0 ]
	then
	    pop2_sumstats1=$pop2_sumstats$chr$by_chr_sumstats
	fi
	plink --bfile $bfile1 \
	      --chr $chr \
	      --clump $pop2_sumstats1 \
	      --clump-field $sumstats_p --clump-snp-field $sumstats_snpID \
	      --clump-p1 1e-2 --clump-p2 1e-1 --clump-kb 1000 --clump-r2 0.01 \
	      --keep $pop2_ld_ids \
	      --extract $pop2_qc_snplist \
	      --out $outdir/clump/$pop2\_$chr
	rm $outdir/clump/$pop2\_$chr.clumped.gz
	gzip $outdir/clump/$pop2\_$chr.clumped
    done
fi

if [ $do_est_beta_pop2 -eq 1  ]
then
    rm $outdir/models/$pop2\_stage1*
    Rscript --vanilla ~/BridgePRS/bin/est_beta_bychr.R \
	    --clump.stem $indir/clump/$pop2 \
	    --sumstats $pop2_sumstats \
	    --thinned.snplist $thinned_snplist \
	    --n.max.locus $n_max_locus \
	    --ld.ids $pop2_ld_ids \
	    --beta.stem $outdir/models/$pop2\_stage1 \
	    --bfile $pop2_ld_bfile \
	    --sumstats.snpID $sumstats_snpID \
	    --sumstats.betaID $sumstats_beta \
	    --sumstats.allele1ID $sumstats_allele1 \
	    --sumstats.allele0ID $sumstats_allele0 \
	    --sumstats.nID $sumstats_n \
	    --sumstats.seID $sumstats_se \
	    --sumstats.frqID $sumstats_frq \
	    --precision FALSE \
	    --lambda 0.05,0.1,0.2,0.5,1,2,5 \
	    --S 0,0.25,0.5,0.75,1 \
	    --n.cores $n_cores \
	    --recomb.file $recomb_pop2_file \
	    --Ne $N_pop2 \
	    --by.chr.sumstats $by_chr_sumstats \
	    --ld.shrink $ld_shrink \
	    --strand.check $strand_check \
	    --by.chr $by_chr
fi

if [ $do_predict_pop2 -eq 1  ]
then
    rm $outdir/$pop2\_stage1*
    Rscript --vanilla ~/BridgePRS/bin/predict_bychr.R \
	    --beta.stem $outdir/models/$pop2\_stage1 \
	    --out.file $outdir/$pop2\_stage1 \
	    --p.thresh 1e-1,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7,1e-8 \
	    --bfile $pop2_bfile \
	    --test.data $pop2_test_data \
	    --valid.data $pop2_valid_data \
	    --n.cores $n_cores \
	    --cov.names $cov_names \
	    --pheno.name $pheno_name \
	    --all.preds TRUE \
	    --ranking "pv" \
	    --strand.check $strand_check \
	    --by.chr $by_chr
fi

if [ $do_combine -eq 1  ]
then
    rm $outdir/$pop2\_weighted_combined_var_explained.txt
    Rscript --vanilla ~/BridgePRS/bin/pred_combine_en.R \
	    --pred1 stage2 \
	    --pred2 stage1 \
	    --pop2 $pop2 \
	    --outdir $outdir \
	    --valid.data $pop2_valid_data \
	    --test.data $pop2_test_data \
	    --n.cores $n_cores \
	    --cov.names $cov_names \
	    --ids.col $ids_col \
	    --pheno.name $pheno_name
fi	    
