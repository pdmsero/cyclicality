use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/bea_naics_three_digit.dta"

. gen code=1 if naics3 == "111.112"
. replace code=2 if naics3 == "113.114.115"
. replace code=3 if naics3 == "211"
. replace code=4 if naics3 == "212"
. replace code=5 if naics3 == "213"
. replace code=6 if naics3 == "321"
. replace code=7 if naics3 == "327"
. replace code=8 if naics3 == "331"
. replace code=9 if naics3 == "332"
. replace code=10 if naics3 == "333"
. replace code=11 if naics3 == "334"
. replace code=12 if naics3 == "335"
. replace code=13 if naics3 == "336"
. replace code=14 if naics3 == "337"
. replace code=15 if naics3 == "339"
. replace code=16 if naics3 == "311"
. replace code=16 if naics3 == "312"
. replace code=17 if naics3 == "313"
. replace code=17 if naics3 == "314"
. replace code=18 if naics3 == "315"
. replace code=18 if naics3 == "316"
. replace code=19 if naics3 == "322"
. replace code=20 if naics3 == "323"
. replace code=21 if naics3 == "324"
. replace code=22 if naics3 == "325"
. replace code=23 if naics3 == "326"
. replace code=24 if naics3 == "481"
. replace code=25 if naics3 == "482"
. replace code=26 if naics3 == "483"
. replace code=27 if naics3 == "484"
. replace code=28 if naics3 == "485"
. replace code=29 if naics3 == "486"
. replace code=30 if naics3 == "487"
. replace code=30 if naics3 == "488"
. replace code=30 if naics3 == "492"
. replace code=31 if naics3 == "493"
. replace code=32 if naics3 == "511"
. replace code=32 if naics3 == "516"
. replace code=33 if naics3 == "512"
. replace code=34 if naics3 == "515"
. replace code=34 if naics3 == "517"
. replace code=35 if naics3 == "518"
. replace code=35 if naics3 == "519"
. replace code=36 if naics3 == "521"
. replace code=36 if naics3 == "522"
. replace code=37 if naics3 == "523"
. replace code=38 if naics3 == "524"
. replace code=39 if naics3 == "525"
. replace code=40 if naics3 == "531"
. replace code=41 if naics3 == "532"
. replace code=41 if naics3 == "533"
. replace code=42 if naics3 == "541"
. replace code=43 if naics3 == "561"
. replace code=44 if naics3 == "562"
. replace code=45 if naics3 == "621"
. replace code=46 if naics3 == "622"
. replace code=46 if naics3 == "623"
. replace code=47 if naics3 == "624"
. replace code=48 if naics3 == "711"
. replace code=48 if naics3 == "712"
. replace code=49 if naics3 == "713"
. replace code=50 if naics3 == "721"
. replace code=51 if naics3 == "722"


rename code code_three


use "/Users/pedroserodio/Dropbox/phd documents/Dissertation/data/compustat.dta"

tostring naics, gen (naics2)
gen naics3 = substr(naics, 1, 3)
drop naics2

. gen code=1 if naics3 == "111"
  replace code=1 if naics3 == "112"
. replace code=2 if naics3 == "113"
. replace code=2 if naics3 == "114"
. replace code=2 if naics3 == "115"
. replace code=3 if naics3 == "211"
. replace code=4 if naics3 == "212"
. replace code=5 if naics3 == "213"
. replace code=6 if naics3 == "321"
. replace code=7 if naics3 == "327"
. replace code=8 if naics3 == "331"
. replace code=9 if naics3 == "332"
. replace code=10 if naics3 == "333"
. replace code=11 if naics3 == "334"
. replace code=12 if naics3 == "335"
. replace code=13 if naics3 == "336"
. replace code=14 if naics3 == "337"
. replace code=15 if naics3 == "339"
. replace code=16 if naics3 == "311.312"
. replace code=17 if naics3 == "313.314"
. replace code=18 if naics3 == "315.316"
. replace code=19 if naics3 == "322"
. replace code=20 if naics3 == "323"
. replace code=21 if naics3 == "324"
. replace code=22 if naics3 == "325"
. replace code=23 if naics3 == "326"
. replace code=24 if naics3 == "481"
. replace code=25 if naics3 == "482"
. replace code=26 if naics3 == "483"
. replace code=27 if naics3 == "484"
. replace code=28 if naics3 == "485"
. replace code=29 if naics3 == "486"
. replace code=30 if naics3 == "487.488.492"
. replace code=31 if naics3 == "493"
. replace code=32 if naics3 == "511.516"
. replace code=33 if naics3 == "512"
. replace code=34 if naics3 == "515.517"
. replace code=35 if naics3 == "518.519"
. replace code=36 if naics3 == "521.522"
. replace code=37 if naics3 == "523"
. replace code=38 if naics3 == "524"
. replace code=39 if naics3 == "525"
. replace code=40 if naics3 == "531"
. replace code=41 if naics3 == "532.533"
. replace code=42 if naics3 == "541"
. replace code=43 if naics3 == "561"
. replace code=44 if naics3 == "562"
. replace code=45 if naics3 == "621"
. replace code=46 if naics3 == "622.623"
. replace code=47 if naics3 == "624"
. replace code=48 if naics3 == "711.712"
. replace code=49 if naics3 == "713"
. replace code=50 if naics3 == "721"
. replace code=51 if naics3 == "722"


rename code code_three


merge m:m code_three year using bea_naics_three_digit.dta

gen code = 0

replace code = 1 if sic == 111
replace code = 1 if sic == 112
replace code = 1 if sic == 115
replace code = 1 if sic == 116
replace code = 1 if sic == 119
replace code = 1 if sic == 119
replace code = 1 if sic == 119
replace code = 1 if sic == 119
replace code = 1 if sic == 119
replace code = 1 if sic == 131 
replace code = 1 if sic == 132
replace code = 1 if sic == 133
replace code = 1 if sic == 133
replace code = 1 if sic == 134
replace code = 1 if sic == 139
replace code = 1 if sic == 139
replace code = 1 if sic == 139
replace code = 1 if sic == 139
replace code = 1 if sic == 139
replace code = 1 if sic == 161
replace code = 1 if sic == 171
replace code = 1 if sic == 171
replace code = 1 if sic == 172
replace code = 1 if sic == 173
replace code = 1 if sic == 174
replace code = 1 if sic == 174
replace code = 1 if sic == 175
replace code = 1 if sic == 175
replace code = 1 if sic == 179
replace code = 1 if sic == 179
replace code = 1 if sic == 181
replace code = 1 if sic == 181
replace code = 1 if sic == 182
replace code = 1 if sic == 182
replace code = 1 if sic == 191
replace code = 1 if sic == 811
replace code = 1 if sic == 831
replace code = 1 if sic == 919
replace code = 1 if sic == 2099
replace code = 1 if sic == 211
replace code = 1 if sic == 212
replace code = 1 if sic == 213
replace code = 1 if sic == 214
replace code = 1 if sic == 214
replace code = 1 if sic == 219
replace code = 1 if sic == 241
replace code = 1 if sic == 241
replace code = 1 if sic == 251
replace code = 1 if sic == 252
replace code = 1 if sic == 253
replace code = 1 if sic == 254
replace code = 1 if sic == 259
replace code = 1 if sic == 271
replace code = 1 if sic == 272
replace code = 1 if sic == 273
replace code = 1 if sic == 273
replace code = 1 if sic == 273
replace code = 1 if sic == 279
replace code = 1 if sic == 279
replace code = 1 if sic == 279
replace code = 1 if sic == 291
replace code = 1 if sic == 919
replace code = 1 if sic == 921
replace code = 1 if sic == 921

replace code = 2 if sic == 811
replace code = 2 if sic == 831
replace code = 2 if sic == 2411
replace code = 2 if sic == 912
replace code = 2 if sic == 913
replace code = 2 if sic == 919
replace code = 2 if sic == 919
replace code = 2 if sic == 971
replace code = 2 if sic == 711
replace code = 2 if sic == 721
replace code = 2 if sic == 722
replace code = 2 if sic == 723
replace code = 2 if sic == 724
replace code = 2 if sic == 751
replace code = 2 if sic == 752
replace code = 2 if sic == 761
replace code = 2 if sic == 762
replace code = 2 if sic == 851
replace code = 2 if sic == 7699

replace code = 3 if sic == 1311
replace code = 3 if sic == 1321
replace code = 3 if sic == 2819

replace code = 4 if sic == 1011
replace code = 4 if sic == 1021
replace code = 4 if sic == 1031
replace code = 4 if sic == 1041
replace code = 4 if sic == 1044
replace code = 4 if sic == 1061
replace code = 4 if sic == 1061
replace code = 4 if sic == 1094
replace code = 4 if sic == 1099
replace code = 4 if sic == 1221
replace code = 4 if sic == 1222
replace code = 4 if sic == 1231
replace code = 4 if sic == 1411
replace code = 4 if sic == 1422
replace code = 4 if sic == 1423
replace code = 4 if sic == 1429
replace code = 4 if sic == 1442
replace code = 4 if sic == 1446
replace code = 4 if sic == 1455
replace code = 4 if sic == 1459
replace code = 4 if sic == 1474
replace code = 4 if sic == 1475
replace code = 4 if sic == 1479
replace code = 4 if sic == 1499
replace code = 4 if sic == 1499
replace code = 4 if sic == 3295
replace code = 4 if sic == 3295
replace code = 4 if sic == 3295
replace code = 4 if sic == 3295

replace code = 5 if sic == 1081
replace code = 5 if sic == 1241
replace code = 5 if sic == 1381
replace code = 5 if sic == 1382
replace code = 5 if sic == 1389
replace code = 5 if sic == 1481

replace code = 6 if sic == 2421
replace code = 6 if sic == 2421
replace code = 6 if sic == 2421
replace code = 6 if sic == 2421
replace code = 6 if sic == 2421
replace code = 6 if sic == 2426
replace code = 6 if sic == 2426
replace code = 6 if sic == 2426
replace code = 6 if sic == 2429
replace code = 6 if sic == 2429
replace code = 6 if sic == 2429
replace code = 6 if sic == 2431
replace code = 6 if sic == 2431
replace code = 6 if sic == 2435
replace code = 6 if sic == 2436
replace code = 6 if sic == 2439
replace code = 6 if sic == 2439
replace code = 6 if sic == 2441
replace code = 6 if sic == 2448
replace code = 6 if sic == 2449
replace code = 6 if sic == 2451
replace code = 6 if sic == 2452
replace code = 6 if sic == 2491
replace code = 6 if sic == 2493
replace code = 6 if sic == 2499
replace code = 6 if sic == 2499
replace code = 6 if sic == 3131
replace code = 6 if sic == 3999

replace code = 7 if sic == 3211
replace code = 7 if sic == 3221
replace code = 7 if sic == 3229
replace code = 7 if sic == 3231
replace code = 7 if sic == 3241
replace code = 7 if sic == 3251
replace code = 7 if sic == 3251
replace code = 7 if sic == 3253
replace code = 7 if sic == 3255
replace code = 7 if sic == 3259
replace code = 7 if sic == 3261
replace code = 7 if sic == 3262
replace code = 7 if sic == 3263
replace code = 7 if sic == 3264
replace code = 7 if sic == 3269
replace code = 7 if sic == 3271
replace code = 7 if sic == 3272
replace code = 7 if sic == 3272
replace code = 7 if sic == 3272
replace code = 7 if sic == 3273
replace code = 7 if sic == 3274
replace code = 7 if sic == 3275
replace code = 7 if sic == 3281
replace code = 7 if sic == 3291
replace code = 7 if sic == 3292
replace code = 7 if sic == 3295
replace code = 7 if sic == 3296
replace code = 7 if sic == 3297
replace code = 7 if sic == 3299
replace code = 7 if sic == 3299
replace code = 7 if sic == 3299
replace code = 7 if sic == 5719

replace code = 8 if sic == 2819
replace code = 8 if sic == 3312
replace code = 8 if sic == 3312
replace code = 8 if sic == 3313
replace code = 8 if sic == 3315
replace code = 8 if sic == 3316
replace code = 8 if sic == 3317
replace code = 8 if sic == 3321
replace code = 8 if sic == 3322
replace code = 8 if sic == 3324
replace code = 8 if sic == 3325
replace code = 8 if sic == 3331
replace code = 8 if sic == 3334
replace code = 8 if sic == 3339
replace code = 8 if sic == 3341
replace code = 8 if sic == 3341
replace code = 8 if sic == 3341
replace code = 8 if sic == 3351
replace code = 8 if sic == 3353
replace code = 8 if sic == 3354
replace code = 8 if sic == 3355
replace code = 8 if sic == 3356
replace code = 8 if sic == 3357
replace code = 8 if sic == 3357
replace code = 8 if sic == 3357
replace code = 8 if sic == 3363
replace code = 8 if sic == 3364
replace code = 8 if sic == 3365
replace code = 8 if sic == 3366
replace code = 8 if sic == 3369
replace code = 8 if sic == 3399
replace code = 8 if sic == 3399
replace code = 8 if sic == 3399
replace code = 8 if sic == 3399
replace code = 8 if sic == 3399

replace code = 9 if naics3 == 3291
replace code = 9 if naics3 == 3315
replace code = 9 if naics3 == 3398
replace code = 9 if naics3 == 3399
replace code = 9 if naics3 == 3399
replace code = 9 if naics3 == 3411
replace code = 9 if naics3 == 3412
replace code = 9 if naics3 == 3421
replace code = 9 if naics3 == 3421
replace code = 9 if naics3 == 3423
replace code = 9 if naics3 == 3425
replace code = 9 if naics3 == 3429
replace code = 9 if naics3 == 3429
replace code = 9 if naics3 == 3429
replace code = 9 if naics3 == 3429
replace code = 9 if naics3 == 3429
replace code = 9 if naics3 == 3431
replace code = 9 if naics3 == 3432
replace code = 9 if naics3 == 3432
replace code = 9 if naics3 == 3432
replace code = 9 if naics3 == 3441
replace code = 9 if naics3 == 3442
replace code = 9 if naics3 == 3443
replace code = 9 if naics3 == 3443
replace code = 9 if naics3 == 3443
replace code = 9 if naics3 == 3444
replace code = 9 if naics3 == 3444
replace code = 9 if naics3 == 3444
replace code = 9 if naics3 == 3446
replace code = 9 if naics3 == 3448
replace code = 9 if naics3 == 3449
replace code = 9 if naics3 == 3449
replace code = 9 if naics3 == 3449
replace code = 9 if naics3 == 3451
replace code = 9 if naics3 == 3452
replace code = 9 if naics3 == 3462
replace code = 9 if naics3 == 3463
replace code = 9 if naics3 == 3466
replace code = 9 if naics3 == 3469
replace code = 9 if naics3 == 3469
replace code = 9 if naics3 == 3469
replace code = 9 if naics3 == 3471
replace code = 9 if naics3 == 3479
replace code = 9 if naics3 == 3482
replace code = 9 if naics3 == 3483
replace code = 9 if naics3 == 3484
replace code = 9 if naics3 == 3489
replace code = 9 if naics3 == 3491
replace code = 9 if naics3 == 3492
replace code = 9 if naics3 == 3493
replace code = 9 if naics3 == 3494
replace code = 9 if naics3 == 3494
replace code = 9 if naics3 == 3495
replace code = 9 if naics3 == 3496
replace code = 9 if naics3 == 3496
replace code = 9 if naics3 == 3497
replace code = 9 if naics3 == 3498
replace code = 9 if naics3 == 3499
replace code = 9 if naics3 == 3499
replace code = 9 if naics3 == 3499
replace code = 9 if naics3 == 3499
replace code = 9 if naics3 == 3499
replace code = 9 if naics3 == 3523
replace code = 9 if naics3 == 3523
replace code = 9 if naics3 == 3524
replace code = 9 if naics3 == 3537
replace code = 9 if naics3 == 3537
replace code = 9 if naics3 == 3543
replace code = 9 if naics3 == 3545
replace code = 9 if naics3 == 3559
replace code = 9 if naics3 == 3562
replace code = 9 if naics3 == 3599
replace code = 9 if naics3 == 3599
replace code = 9 if naics3 == 3599
replace code = 9 if naics3 == 3644
replace code = 9 if naics3 == 3728
replace code = 9 if naics3 == 3841
replace code = 9 if naics3 == 3914
replace code = 9 if naics3 == 3914
replace code = 9 if naics3 == 3999
replace code = 9 if naics3 == 3999
replace code = 9 if naics3 == 3999
replace code = 9 if naics3 == 3999

replace code = 10 if naics3 == sic_03
2499
3429
3433
3443
3444
3496
3511
3519
3523
3523
3524
3531
3531
3532
3533
3534
3535
3536
3537
3541
3542
3544
3544
3545
3546
3547
3548
3549
3552
3553
3554
3555
3556
3559
3559
3559
3559
3559
3561
3563
3564
3564
3565
3566
3567
3568
3569
3569
3578
3578
3579
3581
3582
3585
3586
3589
3593
3594
3596
3599
3599
3634
3639
3699
3699
3699
3743
3799
3827
3861
3999
