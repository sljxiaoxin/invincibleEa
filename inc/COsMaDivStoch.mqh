//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "structs.mqh";

class COsMaDivStoch
{  
   private:
      datetime m_EntrySignalM5Time;
      datetime m_EntrySignalH1Time;
      
      datetime m_ExitSignalM5Time;
      
      datetime m_FillDataM5Time;
      datetime m_FillDataH1Time;
      
      double m_Stoch14M5[20];
      double m_Stoch100M5[20];
      double m_Stoch14H1[20];
      double m_Stoch100H1[20];
      
      Signal* m_CurrentH1Sr;
      
     
      void FillData(int tf, datetime currDt);
      
      
   public:
   
      COsMaDivStoch(){
         //m_CurrentH1Sr = {-1,-1,false,"",""};
         m_CurrentH1Sr = new Signal();
         m_CurrentH1Sr.sign = -1;
         m_CurrentH1Sr.Level = -1;
         m_CurrentH1Sr.unHedg = false;
         m_CurrentH1Sr.strategy = "";
         m_CurrentH1Sr.comment = "";
      };
      Signal* EntrySignalH1(void);
      Signal* ExitSignalH1(void);
      
      int   EntrySignalH1_Buy(void);
      int   EntrySignalH1_Sell(void);
};

void COsMaDivStoch::FillData(int tf, datetime currDt)
{
   int i;
   
   if(tf == PERIOD_M5){
      if(m_FillDataM5Time == currDt){
      
      }else{
         m_FillDataM5Time = currDt;
         for(i=0;i<20;i++){
            m_Stoch14M5[i]  = iStochastic(NULL, PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100M5[i] = iStochastic(NULL, PERIOD_M5, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   if(tf == PERIOD_H1){
      if(m_FillDataH1Time == currDt){
      
      }else{
         m_FillDataH1Time = currDt;
         for(i=0;i<20;i++){
            m_Stoch14H1[i]  = iStochastic(NULL, PERIOD_H1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100H1[i] = iStochastic(NULL, PERIOD_H1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
}


//signal by H1 but M5 for entry
Signal* COsMaDivStoch::EntrySignalH1(void)
{ 
   if(m_EntrySignalH1Time == iTime(NULL,PERIOD_H1,0)){
      
   }else{
      m_EntrySignalH1Time = iTime(NULL,PERIOD_H1,0);
      FillData(PERIOD_H1, m_EntrySignalH1Time);
      
     // m_CurrentH1Sr = {-1,-1,false,"",""};   //reset
      m_CurrentH1Sr.sign = -1;
      m_CurrentH1Sr.Level = -1;
      m_CurrentH1Sr.unHedg = false;
      m_CurrentH1Sr.strategy = "";
      m_CurrentH1Sr.comment = "";
      int level = EntrySignalH1_Buy();
      if(level >0){
         //m_CurrentH1Sr = {OP_BUY,level,false,"COsMaDivStoch","COsMaDivStochH1"};
         m_CurrentH1Sr.sign     = OP_BUY;
         m_CurrentH1Sr.Level    = level;
         m_CurrentH1Sr.unHedg   = false;
         m_CurrentH1Sr.strategy = "COsMaDivStoch";
         m_CurrentH1Sr.comment  = "COsMaDivStochH1";
      }else{
         level = EntrySignalH1_Sell();
         if(level > 0){
            //m_CurrentH1Sr = {OP_SELL,level,false,"COsMaDivStoch","COsMaDivStochH1"};
            m_CurrentH1Sr.sign     = OP_SELL;
            m_CurrentH1Sr.Level    = level;
            m_CurrentH1Sr.unHedg   = false;
            m_CurrentH1Sr.strategy = "COsMaDivStoch";
            m_CurrentH1Sr.comment  = "COsMaDivStochH1";
         }
      }
   }
   
   Signal* sr = new Signal(); //= {-1,-1,"",""};
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   if(m_CurrentH1Sr.sign == -1){
      return sr;
   }
   
   if(m_EntrySignalM5Time == iTime(NULL,PERIOD_M5,0)){
         
   }else{
      m_EntrySignalM5Time = iTime(NULL,PERIOD_M5,0);
      FillData(PERIOD_M5, m_EntrySignalM5Time);
      
      bool isStoch14M5Over = false,isStoch100M5Over = false;
      if(m_CurrentH1Sr.sign == OP_BUY){
         if(m_Stoch14M5[1] >20 && m_Stoch100M5[1]>20 && m_Stoch14H1[1]>11 && m_Stoch100H1[1]>11){
            for(int i=3;i<10;i++){
               if(m_Stoch14M5[i]<11){
                  isStoch14M5Over = true;
               }
               if(m_Stoch100M5[i]<11){
                  isStoch100M5Over = true;
               }
            }
            if(isStoch14M5Over && isStoch100M5Over){
               //sr = {OP_BUY,3,true,"COsMaDivStoch","COsMaDivStochH1"};
               sr.sign = OP_BUY;
               sr.Level = 3;
               sr.unHedg = true;
               sr.strategy = "COsMaDivStoch";
               sr.comment = "COsMaDivStochH1";
               //m_CurrentH1Sr = {-1,-1,"",""};  //reset for next m5 not in
               m_CurrentH1Sr.sign = -1;
               m_CurrentH1Sr.Level = -1;
               m_CurrentH1Sr.unHedg = false;
               m_CurrentH1Sr.strategy = "";
               m_CurrentH1Sr.comment = "";
            }
         }
      }
      if(m_CurrentH1Sr.sign == OP_SELL){
         if(m_Stoch14M5[1] <80 && m_Stoch100M5[1]<80 && m_Stoch14H1[1]<89 && m_Stoch100H1[1]<89){
            for(int i=3;i<10;i++){
               if(m_Stoch14M5[i]>89){
                  isStoch14M5Over = true;
               }
               if(m_Stoch100M5[i]>89){
                  isStoch100M5Over = true;
               }
            }
            if(isStoch14M5Over && isStoch100M5Over){
               //sr = {OP_SELL,3,true,"COsMaDivStoch","COsMaDivStochH1"};
               sr.sign = OP_BUY;
               sr.Level = 3;
               sr.unHedg = true;
               sr.strategy = "COsMaDivStoch";
               sr.comment = "COsMaDivStochH1";
              // m_CurrentH1Sr = {-1,-1,"",""};  //reset for next m5 not in
               m_CurrentH1Sr.sign = -1;
               m_CurrentH1Sr.Level = -1;
               m_CurrentH1Sr.unHedg = false;
               m_CurrentH1Sr.strategy = "";
               m_CurrentH1Sr.comment = "";
            }
         }
      }
   }
   return sr;
}

Signal* COsMaDivStoch::ExitSignalH1(void){

   FillData(PERIOD_H1, iTime(NULL,PERIOD_H1,0));
   string type = "none";
   int level = EntrySignalH1_Buy();
   if(level >0){
      type = "buy";
   }else{
      level = EntrySignalH1_Sell();
      if(level > 0){
         type = "sell";
      }
   }
   Signal* sr = new Signal();// = {-1,-1,false,"",""};
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   if(m_ExitSignalM5Time == iTime(NULL,PERIOD_M5,0)){
         
   }else{
      m_ExitSignalM5Time = iTime(NULL,PERIOD_M5,0);
      FillData(PERIOD_M5, m_ExitSignalM5Time);
      
      bool isStoch14M5Over = false,isStoch100M5Over = false;
      if(type == "buy"){
         if(m_Stoch14M5[1] >20 && m_Stoch100M5[1]>20 && m_Stoch14H1[1]>11 && m_Stoch100H1[1]>11){
            for(int i=3;i<10;i++){
               if(m_Stoch14M5[i]<11){
                  isStoch14M5Over = true;
               }
               if(m_Stoch100M5[i]<11){
                  isStoch100M5Over = true;
               }
            }
            if(isStoch14M5Over && isStoch100M5Over){
               //sr = {OP_SELL,3,false,"COsMaDivStoch","ExitSignalH1"};
               sr.sign = OP_SELL;
               sr.Level = 3;
               sr.unHedg = false;
               sr.strategy = "COsMaDivStoch";
               sr.comment = "ExitSignalH1";
            }
         }
      }
      if(type == "sell"){
         if(m_Stoch14M5[1] <80 && m_Stoch100M5[1]<80 && m_Stoch14H1[1]<89 && m_Stoch100H1[1]<89){
            for(int i=3;i<10;i++){
               if(m_Stoch14M5[i]>89){
                  isStoch14M5Over = true;
               }
               if(m_Stoch100M5[i]>89){
                  isStoch100M5Over = true;
               }
            }
            if(isStoch14M5Over && isStoch100M5Over){
               //sr = {OP_BUY,3,false,"COsMaDivStoch","ExitSignalH1"};
               sr.sign = OP_BUY;
               sr.Level = 3;
               sr.unHedg = false;
               sr.strategy = "COsMaDivStoch";
               sr.comment = "ExitSignalH1";
            }
         }
      }
   }
   return sr;
}




int COsMaDivStoch::EntrySignalH1_Buy(void){
   int level = -1;
   double bullishDivVal1 = iCustom(NULL,PERIOD_M5,"FX5_Divergence_v2.0_yjx",2,1);  //up
   double bullishDivVal2 = iCustom(NULL,PERIOD_M5,"FX5_Divergence_v2.0_yjx",2,2);  //up
   
   if(bullishDivVal1 != EMPTY_VALUE || bullishDivVal2 != EMPTY_VALUE){
      level = 2;
   }
   return level;
}

int COsMaDivStoch::EntrySignalH1_Sell(void){
   int level = -1;
   double bearishDivVal1 = iCustom(NULL,PERIOD_M5,"FX5_Divergence_v2.0_yjx",3,1);  //down
   double bearishDivVal2 = iCustom(NULL,PERIOD_M5,"FX5_Divergence_v2.0_yjx",3,2);  //down
   
   if(bearishDivVal1 != EMPTY_VALUE || bearishDivVal2 != EMPTY_VALUE){
      level = 2;
   }
   return level;
}