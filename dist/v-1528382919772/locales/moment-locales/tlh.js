!function(a,e){"object"==typeof exports&&"undefined"!=typeof module&&"function"==typeof require?e(require("../moment")):"function"==typeof define&&define.amd?define(["../moment"],e):e(a.moment)}(this,function(a){"use strict";function e(a){var e=a;return e=a.indexOf("jaj")!==-1?e.slice(0,-3)+"leS":a.indexOf("jar")!==-1?e.slice(0,-3)+"waQ":a.indexOf("DIS")!==-1?e.slice(0,-3)+"nem":e+" pIq"}function j(a){var e=a;return e=a.indexOf("jaj")!==-1?e.slice(0,-3)+"Hu’":a.indexOf("jar")!==-1?e.slice(0,-3)+"wen":a.indexOf("DIS")!==-1?e.slice(0,-3)+"ben":e+" ret"}function r(a,e,j,r){var n=t(a);switch(j){case"mm":return n+" tup";case"hh":return n+" rep";case"dd":return n+" jaj";case"MM":return n+" jar";case"yy":return n+" DIS"}}function t(a){var e=Math.floor(a%1e3/100),j=Math.floor(a%100/10),r=a%10,t="";return e>0&&(t+=n[e]+"vatlh"),j>0&&(t+=(""!==t?" ":"")+n[j]+"maH"),r>0&&(t+=(""!==t?" ":"")+n[r]),""===t?"pagh":t}var n="pagh_wa’_cha’_wej_loS_vagh_jav_Soch_chorgh_Hut".split("_"),_=a.defineLocale("tlh",{months:"tera’ jar wa’_tera’ jar cha’_tera’ jar wej_tera’ jar loS_tera’ jar vagh_tera’ jar jav_tera’ jar Soch_tera’ jar chorgh_tera’ jar Hut_tera’ jar wa’maH_tera’ jar wa’maH wa’_tera’ jar wa’maH cha’".split("_"),monthsShort:"jar wa’_jar cha’_jar wej_jar loS_jar vagh_jar jav_jar Soch_jar chorgh_jar Hut_jar wa’maH_jar wa’maH wa’_jar wa’maH cha’".split("_"),monthsParseExact:!0,weekdays:"lojmItjaj_DaSjaj_povjaj_ghItlhjaj_loghjaj_buqjaj_ghInjaj".split("_"),weekdaysShort:"lojmItjaj_DaSjaj_povjaj_ghItlhjaj_loghjaj_buqjaj_ghInjaj".split("_"),weekdaysMin:"lojmItjaj_DaSjaj_povjaj_ghItlhjaj_loghjaj_buqjaj_ghInjaj".split("_"),longDateFormat:{LT:"HH:mm",LTS:"HH:mm:ss",L:"DD.MM.YYYY",LL:"D MMMM YYYY",LLL:"D MMMM YYYY HH:mm",LLLL:"dddd, D MMMM YYYY HH:mm"},calendar:{sameDay:"[DaHjaj] LT",nextDay:"[wa’leS] LT",nextWeek:"LLL",lastDay:"[wa’Hu’] LT",lastWeek:"LLL",sameElse:"L"},relativeTime:{future:e,past:j,s:"puS lup",m:"wa’ tup",mm:r,h:"wa’ rep",hh:r,d:"wa’ jaj",dd:r,M:"wa’ jar",MM:r,y:"wa’ DIS",yy:r},dayOfMonthOrdinalParse:/\d{1,2}\./,ordinal:"%d.",week:{dow:1,doy:4}});return _});