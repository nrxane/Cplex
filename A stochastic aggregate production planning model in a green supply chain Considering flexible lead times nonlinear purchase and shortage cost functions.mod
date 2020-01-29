/*********************************************
 * OPL 12.2 Model
 * Author: behnam
 * Creation Date: May 29, 2011 at 6:36:26 PM
 *********************************************/
int BIGM=1000000000;
int nbfact=3;
int nbper=6;
int nbveh=3;
int nbpro=4;
int nbsup=3;
int nbcus=3;
int nbdisc=4;
int nbshort=4;
float alfa=0.3;
int nbdev=51;
range dev=1..nbdev;
range fact=1..nbfact;
range per=1..nbper;
range pro=1..nbpro;
range veh=1..nbveh;
range sup=1..nbsup;
range cus=1..nbcus;
range disc=1..nbdisc;
range short=1..nbshort;
float ss[dev]=...;
float aaa[dev]=...;
float sc[fact]=...;
float fc[fact]=...;
float hc[fact]=...;
float pc[fact]=...;
float cp1[fact]=...;
float eul[fact]=...;
float v[pro]=...;
float tv[veh]=...;
float tf[veh]=...;
float ghg[veh]=...;
float eu[veh]=...;
float vi[veh]=...;
float cp2[cus]=...;
float bl[pro][short]=...;
float ghl[fact][per]=...;
float cr[pro][fact]=...;
float co[pro][fact]=...;
float ci1[pro][fact]=...;
float a[pro][fact]=...;
float ci2[pro][cus]=...;
float p[pro][cus]=...;
int dem2[pro,1..nbcus*nbper]=...;
int d[m in pro, p in cus, s in per]=dem2[m, s+nbper*(p-1)];
float cm2[pro, 1..nbsup*nbdisc] = ...;
float cm[m in pro, p in sup,s in disc] = cm2[m,s+nbdisc*(p-1)];
float r2[pro, 1..nbsup*nbdisc]=...;
float r[m in pro, p in sup, s in disc]= r2[m, s+nbdisc*(p-1)];
float pay2[pro, 1..nbcus*nbshort]=...;
float pay[m in pro, p in cus, s in short]= pay2[m,s+nbshort*(p-1)];
float gama2[pro, 1..nbcus*nbshort]=...;
float gama[m in pro, p in cus, s in short]= gama2[m,s+nbshort*(p-1)];
float xql2[pro, 1..nbsup*nbdisc]=...;
float xql[m in pro, p in sup, s in disc]= xql2[m, s+nbdisc*(p-1)];
int lt12[sup, 1..nbfact*nbveh]=...;
int lt1[m in  sup, p in fact, s in veh]= lt12[m, s+nbveh*(p-1)];
float d1[sup][fact]=...;
float d2[fact][cus]=...;
float cs[pro][sup]=...;
int lt22[fact, 1..nbcus*nbveh]=...;
int lt2[m in fact, p in cus, s in veh]= lt22[m, s+nbveh*(p-1)];
dvar boolean y[fact][per];
dvar boolean www[pro][cus][per][short];
dvar float+ l[fact][per];
dvar float+ f[fact][per];
dvar float+ h[fact][per];
dvar float+ i1[pro][fact][per];
dvar float+ xr[pro][fact][per];
dvar float+ xo[pro][fact][per];
dvar float+ i2[pro][cus][per];
dvar float+ b[pro][cus][per];
dvar float+ xv[sup][fact][veh][per];
dvar float+ yv[fact][cus][veh][per];
dvar float+ yq[pro][fact][cus][veh][per];
dvar boolean ttt[pro][sup][disc][veh][per][disc];
dvar float+ xqm[pro][sup][fact][veh][per][disc];
dvar float+ xq[pro][sup][fact][veh][per];
dvar float+ bq[pro][cus][per][short];
dvar float+ lbq[pro][cus][per][short];
dvar float+ zeta1[pro][cus][per][short][dev];
dvar float lxqm[pro][sup][fact][veh][per][disc];
dvar float+ zeta2 [pro][sup][fact][veh][per][disc][dev];
dvar boolean u [pro][sup][fact][veh][per][disc][dev];
dvar boolean uu [pro][cus][per][short][dev];

//dvar boolean ti[pro][cus][per];
dexpr float human=sum (j in fact, t in per) (sc[j]*l[j][t]+fc[j]*f[j][t]+hc[j]*h[j][t]);
dexpr float inv1=sum (n in pro, j in fact, t in per)ci1[n][j]*i1[n][j][t]; 
dexpr float inv2=sum(n in pro, i in cus, t in per)ci2[n][i]*i2[n][i][t];
dexpr float transfix=sum(k in sup, j in fact, i in cus, g in veh, t in per)tf[g]*(xv[k][j][g][t]+yv[j][i][g][t]);
dexpr float transvar1=sum( k in sup, j in fact, g in veh, t in per) tv[g]*d1[k][j]*xv[k][j][g][t];
dexpr float transvar2=sum(j in fact, i in cus, g in veh, t in per) tv [g]* d2[j][i]*yv[j][j][g][t];
dexpr float prodcost= sum (j in fact, t in per) pc[j]* y[j][t]+ sum(n in pro, j in fact, t in per)(cr[n][j]*xr[n][j][t]+co[n][j]*xo[n][j][t]);
dexpr float income=sum (n in pro, j in fact, i in cus, g in veh, t in per)p[n][i]*yq[n][j][i][g][t];
dexpr float shortage=sum(n in pro, i in cus, t in per, q in 1.. nbshort-1)((pay[n][i][q]-gama[n][i][q]*bl[n][q])*bq[n][i][t][q]+lbq[n][i][t][q]);
dexpr float purchase=sum(n in pro, k in sup, j in fact, g in veh, t in per)(sum (m in 1.. nbdisc-1)((cm[n][k][m]-r[n][k][m]*xql[n][k][m])*xqm[n][k][j][g][t][m]+lxqm[n][k][j][g][t][m]));
dexpr float trans=transfix+transvar1+transvar2;
dexpr float inv=inv1+inv2;
dexpr float totalcost=human+inv+trans+prodcost+purchase+shortage;
dexpr float z=totalcost-income;
minimize z;
subject to{

//9
  forall (n in pro, i in cus) cn9_1: 20 + sum(j in fact, g in veh:1-lt2[j][i][g]>0)yq[n][j][i][g][1-lt2[j][i][g]]-d[n][i][1]==i2[n][i][1]-b[n][i][1]; 
  forall (n in pro, i in cus, t in 2..nbper) cn9_2: i2[n][i][t-1]+sum(j in fact, g in veh:t-lt2[j][i][g]>0)yq[n][j][i][g][t-lt2[j][i][g]]-d[n][i][t]-b[n][i][t-1]==i2[n][i][t]-b[n][i][t];
//10
  forall (n in pro, j in fact)cn10_1: 10 + sum(k in sup, g in veh: 1-lt1[k][j][g]>0)xq[n][k][j][g][1-lt1[k][j][g]]-sum(i in cus, g in veh)yq[n][j][i][g][1]==i1[n][j][1];
  forall (n in pro, j in fact, t in 2..nbper)cn10_2: i1[n][j][t-1]+sum(k in sup, g in veh: t-lt1[k][j][g]>0)xq[n][k][j][g][t-lt1[k][j][g]]-sum(i in cus, g in veh)yq[n][j][i][g][t]==i1[n][j][t];
 //11,12
 forall(j in fact, t in per)cn11:sum(n in pro) a[n][j]*xo[n][j][t]<=alfa*l[j][t];
 forall(j in fact, t in per)cn12:sum(n in pro) a[n][j]*xr[n][j][t]<=l[j][t];
  //13  
 forall (j in fact)cn13_1:l[j][1]==25 + h[j][1]-f[j][1];                 
 forall (j in fact, t in 2..nbper)cn13_2:l[j][t]==l[j][t-1]+h[j][t]-f[j][t];
  //14,15
  forall(j in fact, t in per)cn14:sum(k in sup, g in veh)xv[k][j][g][t]*ghg[g]*d1[k][j]+sum(i in cus, g in veh)yv[j][i][g][t]*ghg[g]*d2[j][i]<=ghl[j][t];
  forall (j in fact)cn15: sum(k in sup, g in veh, t in per) xv[k][j][g][t]*eu[g]*d1[k][j]+sum(i in cus, g in veh, t in per)yv[j][i][g][t]*eu[g]*d2[j][i]<=eul[j];
//16,17,18
forall (n in pro, k in sup, t in per)cn16:sum(j in fact, g in veh)xq[n][k][j][g][t]<=cs[n][k];
forall (j in fact, t in per) cn17:sum(n in pro) i1[n][j][t]<=cp1[j];
forall (i in cus, t in per)cn18: sum(n in pro) i2[n][i][t]<=cp2[i];
//19,20
forall (k in sup, j in fact, g in veh, t in per)cn19:{(xv[k][j][g][t]-1)*vi[g]<=sum(n in pro) v[n]*xq[n][k][j][g][t];
 xv[k][j][g][t]*vi[g]>=sum(n in pro) v[n]*xq[n][k][j][g][t];
}
forall (j in fact, i in cus, g in veh, t in per)cn20:{(yv[j][i][g][t]-1)*vi[g]<=sum(n in pro)v[n]*yq[n][j][i][g][t];
yv[j][i][g][t]*vi[g]>=sum(n in pro)v[n]*yq[n][j][i][g][t];
}
//21
forall(j in fact, t in per)cn21:{y[j][t]<=BIGM*sum(n in pro)(xo[n][j][t]+xr[n][j][t]);
sum(n in pro) (xo[n][j][t]+xr[n][j][t])<= y[j][t]*BIGM;
}
//22,23
forall (n in pro, j in fact, t in per) {cn22:sum(k in sup, g in veh:t-lt1[k][j][g]>0)xq[n][k][j][g][t-lt1[k][j][g]]>=xo[n][j][t]+xr[n][j][t];
cn23:xo[n][j][t]+xr[n][j][t]>=sum(i in cus, g in veh)yq[n][j][i][g][t];
}
//24,25
forall(n in pro, k in sup, j in fact, g in veh, t in per, m in 2..nbdisc){cn24:xql[n][k][m-1]*ttt[n][k][j][g][t][m-1]<=xqm[n][k][j][g][t][m-1];
cn25:xql[n][k][m]*ttt[n][k][j][g][t][m-1]>=xqm[n][k][j][g][t][m-1];
}
//26,27
forall(n in pro, k in sup, j in fact, g in veh, t in per)cn26:sum(m in 1..nbshort-1)xqm[n][k][j][g][t][m]==xq[n][k][j][g][t];
forall(n in pro, k in sup, j in fact, g in veh, t in per)cn27:sum(m in 1..nbshort-1)ttt[n][k][j][g][t][m]==1;
//28,29
forall (n in pro, i in cus, t in per, q in 2..nbdisc){cn28:bl[n][q-1]*www[n][i][t][q-1]<=bq[n][i][t][q-1];
cn29:bl[n][q]*www[n][i][t][q-1]>=bq[n][i][t][q-1];
}
//30,31
forall (n in pro, i in cus, t in per)cn30: sum (q in 1..nbshort-1)www[n][i][t][q]==1;
forall (n in pro, i in cus, t in per)cn31:sum(q in 1..nbshort-1) bq[n][i][t][q]==b[n][i][t];
  //linearization-shortage
forall (n in pro, i in cus, t in per, q in 1..nbshort-1)line1:lbq[n][i][t][q]==(ss[1]*gama[n][i][q]*bq[n][i][t][q]+
sum(o in 2..nbdev-1)(ss[o]-ss[o-1])*gama[n][i][q]*(zeta1[n][i][t][q][o]+bq[n][i][t][q]-aaa[o]));
forall(n in pro, i in cus, t in per, q in 1..nbshort-1, o in dev)bq[n][i][t][q]-aaa[o]+zeta1[n][i][t][q][o]>=0;
//in jadid neveshtam-shortage
//forall (n in pro, i in cus, t in per, q in 1..nbshort-1)( lbq[n][i][t][q]==ss[1]*gama[n][i][q]*bq[n][i][t][q]+
//sum(o in 2..nbdev-1)(ss[o]-ss[o-1])*gama[n][i][q]*(-zeta1[n][i][t][q][o]+uu[n][i][t][q][o]*aaa[o]+bq[n][i][t][q]-aaa[o]));
//forall (n in pro, i in cus, t in per, q in 1..nbshort-1,o in dev)zeta1[n][i][t][q][o]>=bq[n][i][t][q]+BIGM*(uu[n][i][t][q][o]-1);
//linearization-discount
forall(n in pro, k in sup, j in fact, g in veh, t in per, m in 1..nbdisc-1)(lxqm[n][k][j][g][t][m]==ss[1]*r[n][k][m]*xqm[n][k][j][g][t][m]+
sum(o in 2..nbdev-1)(ss[o]-ss[o-1])*r[n][k][m]*(-zeta2[n][k][j][g][t][m][o]+u[n][k][j][g][t][m][o]*aaa[o]+xqm[n][k][j][g][t][m]-aaa[o]));
forall (n in pro, k in sup, j in fact, g in veh, t in per, m in 1..nbdisc-1,o in dev)zeta2[n][k][j][g][t][m][o]>=xqm[n][k][j][g][t][m]+BIGM*(u[n][k][j][g][t][m][o]-1);
//jadid-discount
//forall (n in pro, k in sup,j in fact, g in veh, t in per, m in 1..nbdisc-1)lxqm[n][k][j][g][t][m]==(ss[1]*r[n][k][m]*xqm[n][k][j][g][t][m]+
//sum(o in 2..nbdev-1)(ss[o]-ss[o-1])*r[n][k][m]*(zeta2[n][k][j][g][t][m][o]+xqm[n][k][j][g][t][m]-aaa[o]));
//forall(n in pro, k in sup,j in fact, g in veh, t in per, m in 1..nbdisc-1, o in dev)xqm[n][k][j][g][t][m]-aaa[o]+zeta2[n][k][j][g][t][m][o]>=0;
//in jadid neveshtam-shortage


} 
execute DISPLAY {
   //plan[m][j] describes how much to make, sell, and hold of each product j in each month m
   for(var n in pro)
      for(var i in cus )
      for(var t in per)
         writeln("prod:",n,",cus:",i,",per:",t,"=>shortage=",b[n][i][t],"Inventory=",i2[n][i][t]);
}
