//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015."
#property link      "http://www.mql5.com"

class CFilter
{
   private:
      
      bool m_IsFilter;
   public:
      
      CFilter(){
        
      };
      
      void setFilter(bool filter);
      bool check(void);
};

void CFilter::setFilter(bool filter){
   m_IsFilter = filter;
}

bool CFilter::check(){
   //TODO
   return true;
}

