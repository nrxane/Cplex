/*********************************************
 * OPL 12.6.0.0 Model
 * Author: Pouya
 * Creation Date: Jan 20, 2020 at 12:47:02 AM
 *********************************************/
     //Sets
int P = ...;
int nbn = ...;
int nbm = ...;
int nbr = ...;
{int} N = asSet(1..nbn); //Set of pickup and delivery nodes,N={1,2,�,|N|}.
{int} M = asSet(100..nbm); //Set of manufacturing depots,M={1,2,�,|M|}.
{int} R = asSet(200..nbr); //Set of remanufacturing depots, R={1,2,�,|R|}.

{int} V = N union M union R; //Set of all locations,V=(N union M union R).

tuple Arcs{
int i; //Origin Nodes
int j; //Destination Nodes
};
setof (Arcs) A = {<i,j> | i,j in V : i!=j}; //Set of arcs,A = {(i,j):i,j in V,i!=j}.

int nbkm = ...;
int nbkr = ...;
{int} Km = asSet(1..nbkm); //Set of vehicles that serve manufacturing depots,Km={1,2,�,|Km|}.
{int} Kr = asSet(1..nbkr); //Set of vehicles that serve remanufacturing depots,Kr={1,2,�,|Kr|}.

{int} K = Km union Kr; //Set of vehicles,K=(Km union Kr).

int nbt = 12;
{int} T = asSet(1..nbt); //Set of planning periods,T={1,2,�,|T|}.

int nbnkt = ...;
{int} Nkt = asSet(1..nbnkt);
//Set of pickup and delivery nodes that can be served by vehicle k in period t,Nkt={1,2,�,|Nkt|}, and |Nkt|<=|N|.
int nbmkt = ...;
{int} Mkt = asSet(1..nbmkt);
//Set of manufacturing depots that can be served by vehicle k in period t,Mkt={1,2,�,|Mkt|}, and |Mkt|<=|M|.
int nbrkt = ...;
{int} Rkt = asSet(1..nbrkt);
//Set of remanufacturing depots that can be served by vehicle k in period t,Rkt={1,2,�,|Rkt|}, and |Rkt|<=|R|.

{int} Vkt = Nkt union Mkt union Rkt; 
//Set of all locations that can be visited by vehicle k in period t,Vkt=(Nkt union Mkt union Rkt).


     //Parameters
float Q[K] = ...; //Capacity of vehicle k (k in K);
float Cm[M] = ...; //manufacturing capacity at manufacturing depot i;
float Cr[R] = ...; //remanufacturing capacity at remanufacturing depot i;
float cfm = ...; //fixed manufacturing setup costs;
float cm = ...; //unit manufacturing costs;
float cfr = ...; //fixed remanufacturing setup costs;
float cr = ...; //unit remanufacturing costs;
float c[A] = ...; //transportation cost over arc (i,j);
int Sigma[N][T] = ...; //delivery requests of customer i in period t;
int Pi[N][T] = ...; //pickup requests of customer i in period t;
float hd[V] = ...; //unit inventory holding cost of deliveries at customer i or depot i;
float hp[N union R] = ...; //unit inventory holding cost of pickups at customer i or at remanufacturing depot i;
float Ld[V] = ...; //storage capacity for deliveries at customer i or depot i;
float Lp[V] = ...; //storage capacity for pickups at customer i or depot i;
float Id[V] = ...; //initial delivery inventory at customer i or depot i;
float Ip[V] = ...; //initial pickup inventory at customer i or depot i;

/////** Min between some parameters**//////
float B1[i in V][t in T] = minl (Cm[i] , Ld[i] , sum (t in T , i in N) Sigma[i][t]);
float B2[i in V][t in T] = minl (Cr[i] , Lp[i] , sum (t in T , i in N) Sigma[i][t]);
float M1[i in V][t in T][k in K] = minl (Q[k] , Ld[i] , sum (t in T) Sigma[i][t]);
float M2[i in V][t in T][k in K] = minl (Q[k] , Lp[i] , Ip[i] + sum (t in T) Pi[i][t]);

     //Decision Variables
dvar float+ m[M][T]; 
//manufacturing quantity at manufacturing depot i in period t;
dvar float+ r[R][T]; 
//remanufacturing quantity at remanufacturing depot i in period t;
dvar float+ IP[V][T]; 
//delivery inventory at customer i or depot i at the end of period t;
dvar float+ ID[V][T]; 
//pickup inventory at customer i or depot i at the end of period t;
dvar float+ d[N][K][T]; 
//delivery amount to customer i by vehicle k in period t;
dvar float+ p[N][K][T]; 
//pickup amount at customer i by vehicle k in period t;
dvar boolean u[A][K][T]; 
//pickup amount over arc (i,j) by vehicle k in period t if arc (i,j) is traversed by vehicle k in period t, 0 otherwise;
dvar boolean v[A][K][T]; 
//delivery amount over arc (i,j) by vehicle k in period t if arc (i,j) is traversed by vehicle k in period t, 0 otherwise;
dvar boolean x[A][K][T]; 
//binary variable, equal to 1 if arc (i,j) is traversed by vehicle k in period t, 0 otherwise;
dvar boolean y[M][T]; 
//binary variable, equal to 1 if manufacturing is set up for production at manufacturing depot i in period t, 0 otherwise;
dvar boolean z[R][T]; 
//binary variable, equal to 1 if remanufacturing is set up for production at remanufacturing depot i in period t, 0 otherwise;

     //Decision Expression
 //Objective Function
dexpr float PRPRPD = sum (t in T , i in M) (cm * m[i][t] + cfm * y[i][t])
                   + sum (t in T , i in R) (cr * r[i][t] + cfr * z[i][t])
                   + sum (t in T , i in V) (hd[i] * ID[i][t] + hp[i] * IP[i][t])
                   + sum (t in T , k in K , <i,j> in A) (c[<i,j>] * x[<i,j>][k][t]);

     //Model
   
 //Objective Function
minimize PRPRPD;

 //Constraint
subject to {
 forall (i in M , t in T)
C1:  ID[i][t-1] + m[i][t] - sum(k in Km , j in N)d[j][k][t] == ID[i][t];
 forall (i in R, t in T)
C2:  IP[i][t-1] + r[i][t] - sum (k in Kr , j in N) d[j][k][t] == ID[i][t];
 forall (i in R, t in T)
C3:  IP[i][t-1] + r[i][t] / P + sum (k in Kr , j in N) p[j][k][t] == IP[i][t];
 forall (i in N , t in T)
C4:  ID[i][t-1] + sum (k in K) d[i][k][t] - Sigma[i][t] == IP[i][t];
 forall (i in N , t in T)
C5:   IP[i][t-1] + sum (k in K) p[i][k][t] + Pi[i][t] == IP[i][t];
 forall (i in R , t in T)
C6:  r[i][t] <= P * IP[i][t-1];
 forall (i in M , t in T)
C7:  m[i][t] <= B1[i][t] * y[i][t];
 forall (i in R , t in T)
C8:  r[i][t] <= B2[i][t] * z[i][t];
 forall (i in V , t in T)
C9:  ID[i][t] <= Ld[i];
 forall (i in V , t in T)
C10: IP[i][t] <= Lp[i];
 forall (i in Vkt , k in K , t in T)
C11: sum (j in V) x[<i,j>][k][t] <= 1;
 forall (i in Vkt , k in K , t in T)
C12: sum (j in V) x[<i,j>][k][t] - sum(j in V) x[<j,i>][k][t] == 0;
 forall (i in Nkt , k in K , t in T)
C13: sum (j in V) v[<i,j>][k][t] - sum(j in V) v[<j,i>][k][t] == d[i][k][t];
 forall (i in Nkt , k in K , t in T)
C14: sum (j in V) u[<i,j>][k][t] - sum(j in V) u[<j,i>][k][t] == p[i][k][t];
forall (i,j in V , k in K , t in T)
C15: v[<i,j>][k][t] + u[<i,j>][k][t] <= Q[k] * x[<i,j>][k][t];
 forall (i in Nkt , k in K , t in T)
C16: d[i][k][t] <= M1[i][t][k] * sum (j in V)x[<i,j>][k][t];
 forall (i in Nkt , k in Kr , t in T)
C17: p[i][k][t] <= M2[i][k][t] * sum (j in V)x[<i,j>][k][t];
};