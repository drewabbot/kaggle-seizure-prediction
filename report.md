
<html><head>
<title>QMSDP on Seizure Prediction</title>
</head>


<body bgcolor="white" text="black" link="blue" alink="red" vlink="blue">

<table width="77%">
<tbody>
<tr>
<td>

<p>
<b>QMSDP on Seizure Prediction</b>
</p>

<p>
Quang M. Tieng, Min Chen and Simone C. Bosshard, The University of Queensland, Brisbane, AUS <br>
Drew W. Abbot and Phillip C. Adkins, AiLive Inc., Sunnyvale, CA, USA
</p>

<p>
1. Summary
</p>

<p>
This document describes our winning submission of the American Epilepsy Society Seizure Prediction Challenge hosted by Kaggle.com.
</p>

<p>
To begin, note that our team merged together after working the contest independently and combined different approaches and ideas to achieve the final result.  Our winning submission was a weighted average of three separate models: a Generalized Linear Model regression with Lasso or elastic net regularization (via MATLAB's lassoglm function), a Random Forest (via MATLAB's TreeBagger implementation), and a bagged set of linear Support Vector Machines (via Python's scikit-learn toolkit).
</p>

<p>
2. Feature Selection
</p>

<p>
Before merging as a team, we developed different feature sets for our models.
</p>

<p>
For the Lasso GLM model, the features (now referred to as the "Q features") were as follows:
</p>

<p>
1. Spectrum and Shannon's entropy at six frequency bands: delta (0.1-4Hz), theta (4-8Hz), alpha (8-12Hz), beta (12-30Hz), low-gamma (30-70Hz) and high gamma (70-180Hz). <br>
2. Spectral edge power of 50% power up to 40Hz. <br>
3. Shannon's entropy at dyadic frequency bands. <br>
4. Spectrum correlation across channels at dyadic frequency bands. <br>
5. Time-series correlation matrix and its eigenvalues. <br>
6. Fractal dimensions. <br>
7. Hjorth parameters: activity, mobility and complexity. <br>
8. Statistical moments: skewness and kurtosis. <br>
</p>

<p>
Like the Q features, the features for the Random Forest model (now referred to as the "D features") were also a combination of time- and frequency-domain information, and were chosen as:
</p>

<p>
1. Sums of FFT power over hand-picked bands spanning frequencies: f0 (fundamental frequency of FFT), 1Hz, 4Hz, 8Hz, 16Hz, 32Hz, 64Hz, 128Hz and Nyquist.  DC was also included, yielding 9 bands per channel. <br>
2. Time-series correlation matrix. <br>
3. Time-series variance. <br>
</p>

<p>
For the bagged SVM model, the features involved a kernel PCA decomposition of the D features.  Truncating the basis performed a type of regularization.  In order to ensure that the regularized (truncated) KPCA basis adequately explained the test set, the test set was included in the fitting of the KPCA basis.
</p>

<p>
Important differences to highlight for the two source feature sets include the window length and the amount of overlap.  While we experimented with various window lengths, the window lengths for the Q features were typically around 1 minute or longer, and the window lengths for the D features were around 10 seconds or less.  Also, the Q features used no time-series overlap, but the D features took overlap to the extreme, up to 31/32 (or 96.875%) and even 63/64 (or 98.4375%) overlap, yielding many samples for each 10-minute segment.
</p>

<p>
3. Modeling Techniques and Approaches
</p>

<p>
3.1. Q features and Lasso GLM
</p>

<p>
Working with the Q features, we tried several models, including Support Vector Machines (SVMs), Random Forests, Generalized Linear Models (GLMs), and GLM regression with lasso or elastic net regularization (Lasso GLM) outperformed other classifiers.
</p>

<p>
With Lasso GLM, we attempted to choose optimal features by gradually removing feature sets, one set at a time.  To achieve the best results, we ended up removing the fractal dimensions, time-series correlation matrix, and Shannon's entropy at six bands.
</p>

<p>
After feature optimization, we attempted to optimize the number of time-series windows used for each 10-minute segment.  We observed that the prediction performance of the dogs and humans was not the same given the same temporal length segment, so rather than dividing the data into equal-length segments for both dogs and humans, we divided the length of each segment based on the sampling frequency.  As a result, we ended up choosing 12 and 150 windows for each 10-minute segment for dogs and humans, respectively, yielding about 20k samples per window (exactly 20k for the humans, but slightly less so for the dogs, whose sample rate wasn't exactly 400 Hz).  Finally, to collapse the scores for each 10-minute segment down to a single a score, the mean, median, and RMS were attempted, but in the end, the mean was chosen.
</p>

<p>
Other parameters of the Lasso GLM model were tuned, as well.  For example, since our features were highly correlated, we set Alpha to 0.1, which made elastic net approach ridge regression.  Further, a lambda value of 10^-3 seemed to achieve the best results.
</p>

<p>
Once the contest was over, we realized that using 10 windows (or, simply the 1-minute window) for all subjects actually yielded a better private LB score than the 12- and 150-window choice for dogs and humans, respectively.  See section 6 for more in-depth information on this.
</p>

<p>
3.2. D features and Random Forest
</p>

<p>
Roughly half of the D features were frequency-domain features, and the signal processing-based intuition when these features were created was that the signals should be stationary over the time window used in the FFT.  So, while the experimental window length for the Q features decreased from minutes down to roughly one minute, the window length used for the D features was relatively shorter, and increased from 1 second up to 12 seconds.  After analysis, and using a Random Forest with 80 trees, the optimal window length was chosen to be 8 seconds.
</p>

<p>
Analysis showed that using more time-series overlap (which yielded more samples for each 10-minute segment) achieved better results with the Random Forest.  Thus, the overlap was gradually increased all the way up 31/32 for building the model.  This yielded 2366 and 2369 samples per 10-minute segment for dogs and humans, respectively, and the scores were collapsed into a single score for each 10-minute segment by taking a p-norm.  Interestingly, when using MATLAB's TreeBagger Random Forest implementation, the optimal p used in the p-norm seemed larger than we expected.
</p>

<p>
Once the whopping 31/32 overlap was reached, we visualized the resultant "signal" of scores for each 10-minute segment, and we noticed that the signal started to resemble a continuous function.  Thus, we decided that interpolating the signal by a factor of K before taking the final p-norm was worth trying, and indeed, marginal public LB improvements were achieved after doing so (using cubic spline interpolation).  In the end, we decided to use Random Forest models trained on 31/32 overlapped preictal and interictal features to classify 63/64 overlapped test features (yielding 4732 and 4737 samples for each 10-minute segment), and interpolate and p-norm those scores for our final Random Forest model.  Interestingly, as overlap and interpolation increased, the optimal p used in the p-norm seemed to increase as well, and our final choices for K and p ended up being 8 and 23, respectively.  See section 6 for more in-depth information on all of this.
</p>

<p>
3.3. KPCA-Transformed D features and Bagged SVMs
</p>

<p>
The third model chosen for the final ensemble was a bagged set of linear Support Vector Machines (SVMs).  Bagging was chosen to yield a measure of probability.  Due to the large number of nearly redundant samples in the 31/32 overlapped D features, each bag was trained on only 10% of the data.  SVMs with radial basis functions would have likely been preferable, but linear SVMs were chosen due to their runtime training efficiency.
</p>

<p>
In order to emulate the nonlinear basis given by radial basis functions, we performed a kernel PCA decomposition on the 31/32 overlapped D features before inputting into linear SVMs.  Truncating the basis performed a type of regularization.  In order to ensure that the regularized (truncated) KPCA basis adequately explains the test set, the test set was included in fitting of the KPCA basis.
</p>

<p>
As with the Random Forest model, the final output involved taking a p-norm of all scores for each 10-minute segment, but unlike the Random Forest, increasingly higher p-norms did not help, so a p-norm of 2 (or, RMS) was chosen for this model.
</p>

<p>
3.4. Median Centering
</p>

<p>
Due to how the final AUC score was calculated for the contest, there was a question of how to best "calibrate" the probabilities for each model.  Our intuition was that simply "median centering" the scores would be fruitful, and public LB results confirmed this for each model.  Thus, for our final submission, each model used was median centered before ensembling.
</p>

<p>
We implemented median centering by first taking the median score across all test segments for each subject, and then subtracting that median from the scores.  Then, the scores were divided by 2 (to avoid possible loss of information due to clipping) and finally, added to 0.5, so in effect, "centering" the scores around 0.5.
</p>


<p>
3.5. Ensembling
</p>

<p>
After median-centering each of the models' scores, we averaged models, and discovered ensembles of models which performed better than any of the individual models alone.  After experimenting with different ways of ensembling, our final choice was a weighted average of the form: ( 1/4 * Random Forest + 1/4 * Bagged SVM + 1/2 * Lasso GLM ).  This weighted average can also be thought of as taking two means in sequence, like so: ( ( Random Forest + Bagged SVM ) / 2 + Lasso GLM ) / 2.
</p>

<p>
The public and private LB median-centered scores for the models we chose were generally in these ballparks:
</p>

<pre>
  Random Forest: 78% 72%
     Bagged SVM: 79% 75%
      Lasso GLM: 84% 81%
</pre>

<p>
Averaging the Random Forest and Bagged SVM models typically yielded public and private scores of 83% and 78%, and the final ensemble yielded 86% and 82%.  Interestingly, once the contest was over, we realized that using the geometric mean tended to score better than the arithmetic mean and the harmonic mean was generally better than both, and we were later able to achieve almost 83.5% on the private LB using our ensemble.  For more information, see section 6.
</p>


<p>
4. Code Summary
</p>

<p>
Since our winning submission involved three independent codebases (again, two from MATLAB and one from Python), we merged the three codebases into one to ease reproduction of the submission for users, and decided on MATLAB as the core driver.  The final code is available at <a href="http://github.com/drewabbot/kaggle-seizure-prediction">http://github.com/drewabbot/kaggle-seizure-prediction</a>.
</p>

<p>
The MATLAB code has been tested using MATLAB version 8.3.0.532 (R2014a) on 64-bit Ubuntu 14.04 LTS.  The Python code has been tested using Python 2.7, and has the following dependencies: numpy, scipy, pandas, and scikit-learn >= 0.15 (which includes the BaggingClassifer class).


</p><p>
The top-level layout of the code is arranged as follows:
</p>

<pre>
  drew/
   - MATLAB functions to generate D features and Random Forest model
  phil/
   - Python functions to generate KPCA decomposition of D features and bagged SVM model
  qms/
   - MATLAB functions to generate Q features and lassoglm model
  scripts/
   - miscellaneous Python scripts for post-processing submission files, including
     taking p-norms, median centering, and model averaging
  vgo.m
   - main entry point to generate winning submission from scratch
</pre>

<p>
And, here's a more in-depth description of the code:
</p>

<pre>
  drew/
    gogo_treebagger.m
     - main entry point to generate the Random Forest models, use them to classify
       the test data, and generate the final submission file
    save_features.m
     - calculates the D features for a given subject and class (preictal,
       interictal or test), and saves the results to a binary file in the
       specificied output directory
     - calls get_feature_parameters.m to construct the parameters used to calculate
       the feautures, and for each 10-minute segment, calls load_segment.m to load
       the competition data and get_features.m to actually calculate the features
    train_and_compact.m
     - assuming both the D features have already been built for the given subject,
       trains a Random Forest model on those features using MATLAB's TreeBagger
       implementation, and then saves a compacted version of the model to a .mat
       file in the specificied output directory
    load_and_classify_by_segment.m
     - loads a saved CompactTreeBagger model for a given subject, uses it to classify
       the test data, and outputs a sequence of scores for each 10-minute segment
    scores_interp.m
     - interpolates the scores for each 10-minute segment by a factor of K 
        (and currently assumes 63/64 overlapped D features were used)
    median_center.m
     - a wrapper of the Python script used for median centering a submission file

  phil/
    gogo_bagged_svm.m
     - main entry point to perform the KPCA decomposition of the D features,
       generate the bagged SVM models, use them to classify the test data, 
       and generate the final submission file
    kpca.py
     - Python script to perform the KPCA decomposition of D features located in a
       given input directory, and save the results to a given output directory
    bagged_svm.py
     - Python script to build the bagged SVM models, and save raw scores for 
       each 10-minute segment to a given output directory

  qms/
    gogo_lassoglm.m
     - main entry point to build the Q features, generate the Lasso GLM models, 
       use them to classify the test data, and generate the final submission file
     - calls QT_preictal_lassoglm_misc_rm2_11_select.m for each subject to generate
       pre-median centered scores
    QT_6_freq_bands.m
     - used to calculate Q feature sets 1 and 2
    QT_dyadic_spectrum.m
     - used to calculate Q feature sets 3 and 4
    QT_eig_corr.m
     - used to calculate Q feature set 5
    QT_fractal_dimensions.m
     - used to calculate Q feature set 6
    QT_hjorth.m
     - used to calculate Q feature set 7
    QT_statistical_moments.m
     - used to calculate Q feature set 8

  scripts/
    csv_pnorm.py
     - a script to collapse multiple test scores per 10-minute segment into
       a single score, by taking the p-norm
    csv_median_center.py
     - a script used for median centering a submission file
    csv_avg2.py
     - a script used to average two submission files
    csv_cmp.py
     - a script used to compare two submission files for approximate equality
 
  vgo.m
   - again, the main entry point to generate winning submission from scratch
</pre>


<p>
5. Running the Code
</p>

<p>
Given input directory 'ipath' where the original Kaggle competition data is stored and output directory 'opath' used to store features, models, and submission files, running the code from scratch is as simple as:
</p>

<pre>
  ipath = '/path/to/kaggle/competition_data';
  opath = '../data';

  vgo( ipath, opath );
</pre>

<p>
Note that to successfully run the code, a system with at least 16 GB RAM and 16 GB swap space is required, and the output directory must be capable of storing over 105 GB of data.
</p>

<p>
Further, running the code from scratch via the simple vgo.m interface as shown above will take several days to complete (even on a fast system), mainly due to the long time required for saving the 31/32 and 63/64 overlapped D features and since the loop to generate them is single-threaded.  To speed things up, the gogo_features() and go_fx() functions inside vgo.m could be called manually in separate MATLAB instances to generate features for different subjects at the same time.
</p>

<p>
In addition to other data, once completed, vgo.m will have generated many submission files in the 'submissions' sub-directory of the specified output directory.  Important ones to highlight are:
</p>

<pre>
  raw scores from the Random Forest, Bagged SVM, and Lasso GLM models:
    treebagger.up8.p23.0.csv
    bagged_svm.p2.0.csv
    lassoglm.csv

  median-centered versions of those:
    treebagger.up8.p23.0.medcent.csv
    bagged_svm.p2.0.medcent.csv
    lassoglm.medcent.csv

  the average of the median-centered Random Forest and Bagged SVM:
    tale_of_two_cities.csv

  the final winning submission:
    the_power_of_three.csv
</pre>

<p>
6. Additional Analysis and Final Results
</p>

<p>
6.1. Q features and Lasso GLM
</p>

<p>
Recall that in our attempt to optimize the number of time-series windows used for each 10-minute segment, we settled on using 12 windows for dogs and 150 windows for humans.  We also attempted to optimize the features, deciding to remove the fractal dimensions, time-series correlation matrix, and Shannon's entropy at six bands.  While these variations on the feature set resulted in an up to nearly 2% difference on the public LB score, the effects on the private LB were less significant.  Here's a chart comparing the final public and private LB results using the Q features and Lasso GLM model, alone.
</p>

<pre>
  Q features     dog and human divisions        raw scores       median-centered scores
   removed        per 10-minute segment

     2,9,11       12,150 (~20000 samples)     0.81504 0.80103       0.84767 0.81196
     2,9,11       10,10 (1-minute window)     0.81212 0.80665       0.82982 0.81810
   1,2,9,11       10,10 (1-minute window)     0.80566 0.80448       0.83121 0.81963

 Legend for Q features removed:
   1. Eigenvalues of time-series correlation matrix
   2. Time-series correlation matrix
   9. Shannon's entropy at six bands
  11. Fractal dimensions
</pre>

<p>
6.2. D features and Random Forest
</p>

<p>
Recall that since an 8-second window and significant overlap was used for the D features, there ended up being thousands of scores for each 10-minute segment, and as overlap increased, the sequence of scores resembled a continuous function. As our p-norm score reduction resembles an integral, we reconceptualized the reduction as an integration operation, and attempted to increase the accuracy of the model by increasing the accuracy of the integration. To this end, we 8x-interpolated the sequence of scores (using cubic spline interpolation) before p-norm score reduction.
</p>

<p>
Initially the interpolation yielded incremental gains on the public LB and became part of the Random Forest model.  This observation was made before the introduction of median-centering.  However, post-contest analysis revealed that on median-centered data, interpolating the scores made almost no difference at all.  We mention the interpolation as we did not remove it from our source code, but we don't recommend it if using median-centered predictions.  To illustrate, here's a chart comparing the final public and private LB results using the D features and Random Forest model, all of which were median-centered.
</p>

<pre>
          8x-interpolation       no interpolation
 
  p = 2   0.76862  0.72227       0.76863  0.72233
      3   0.77469  0.72438       0.77485  0.72439
      4   0.77730  0.72539       0.77742  0.72545
      5   0.77913  0.72614       0.77925  0.72610
      6   0.78062  0.72704       0.78087  0.72702
      7   0.78216  0.72700       0.78223  0.72705
      8   0.78313  0.72657       0.78319  0.72642
      ..                        .. 
     23   0.79018  0.72189       0.79022  0.72126
</pre>

<p>
6.3. Ensembling
</p>

<p>
Our final choice for the Random Forest model was p=23 and 8x-interpolation.  We overfitted the Random Forest a little in choosing the value of p, but ensembling mitigated this and actually resulted in a higher score overall than with lower values of p, as shown below.
</p>

<pre>
  Ensembling with the 12,150 Lasso GLM:

           arithmetic        geometric         harmonic
 p=6:   0.85495	0.81899   0.85530 0.81980   0.85572 0.82044	
  23:   0.85951 0.81962   0.85967 0.82126   0.86027 0.82216
  31:   0.85998	0.82063   0.86041 0.82147   0.86090 0.82217
</pre>

<p>
So, for the final ensemble a large p-norm for the Random Forest yielded marginal benefits, on both public and private LBs.  Also note that in general, the geometric mean was better than the arithmetic mean, and the harmonic mean was better than both.  Finally, even when using the 1-minute window Lasso GLM models, those results continued to hold, as shown in the charts below.
</p>

<pre>
  Ensembling with the 10,10 Lasso GLM, removing features 2,9,11:

           arithmetic        geometric         harmonic
 p=6:   0.84497	0.82943   0.84612 0.83010   0.84713 0.83035
  23:   0.84881	0.83245   0.84978 0.83294   0.85121 0.83315
  31:   0.84970	0.83288   0.85049 0.83335   0.85171 0.83336

  Ensembling with the 10,10 Lasso GLM, removing features 1,2,9,11:

           arithmetic        geometric         harmonic
 p=6:   0.84714 0.82986   0.84763 0.83066   0.84823 0.83116
  23:   0.85067 0.83301   0.85177 0.83360   0.85226 0.83385
  31:   0.85148 0.83347   0.85248 0.83398   0.85289 0.83436
</pre>

<p>
Thus, as in the 1-minute Lasso GLM models alone, removing the eigenvalue features seemed to help for the final ensemble, and again, the harmonic mean gave the best results.
</p>


<br>
<br>


</td>
</tr>
</tbody>
</table>


</body>
</html>
