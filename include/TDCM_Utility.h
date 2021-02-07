// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM__UTILITY_INCLUDE_FILE__
#define __TDCM__UTILITY_INCLUDE_FILE__
#include "TDCM_Vector.h"
#include "TDCM_String.h"
#include <stdio.h>

namespace TDCM{
  class DoubleVector:public Vector<double>{
  public:
    DoubleVector();
     
    void calculateStatistics();
    double getSum(){return this->_sum;}
    double getAverage(){return this->_average;}
    double getMinimium(){return this->_min;}
    double getMaximium(){return this->_max;}
  private:
    void* data;
    double _sum;
    double _min;
    double _max;
    double _average;
  };

  class SummaryData{
  public:
    String name;
    double value;
  };

  class Summary{				
  public:
    Summary();
    Summary(String _iName,String _dName);
    ~Summary();
							
    void clear();
    void append(const char* mName,double value);

    String& getIName();
    String& getDName();
    Vector<SummaryData>* getSummary();

  protected:
    String iName;
    String dName;
    Vector<SummaryData> summary;
  };

  enum CSVDataType{
    CSVUnknownType = 0,
    CSVVectorType = 1,
    CSVMatrixType = 2
  };

  class InputFile{
  public:
    InputFile(const char* name);
    ~InputFile();
    
    bool  open();
    void  close();
    char* readline();
    char* getBuffer();

  private:
    String fileName;
    char line[4048];
    FILE* file;
  };

  
  class Package;
  class CSVData{
  private:
    static bool _errorOccured;
    static String _error;
  public:
    static void clearError();
    static void reportError(const char* _err);
    static bool errorOccured();
    static const char* error();
    static CSVData* parse(Package* package,const char* fileName);
    static CSVData* parse(const char* fileName);
  private:
    static bool readFileType(InputFile& file,
			     CSVDataType* fileType,
			     const char* fileName);
    static bool readVectorTitle(InputFile& file,
				String& title,
				const char* fileName);
    static bool readIndpendentName(InputFile& in,String& x,
				   String& y);
    static bool readMatrixIndpendentName(InputFile& file,
					 String* x,String* y);
    static void populate(Vector<String> &record, 
			 const char* line,
			 char delimiter);
  public:
    CSVData(int row,int col);
    virtual ~CSVData();
    virtual CSVDataType type() = 0;
    virtual void dump(FILE* file) = 0;
    void setTitle(String s);

    String& getTitle();

    double** __getData();
    double*  __getXData();
    double*  __getYData();

    int getRows();
    int getCols();

  protected:
    static int search(double* v,int size,double value);

  protected:
    String _title;
    int _rows;
    int _cols;
    double** _data;
    double* _xData;
    double* _yData;
  };

  class CSVMatrix:public CSVData{
  public:
    CSVMatrix(int _rows,int _cols);
    virtual CSVDataType type();
    virtual void dump(FILE* file);
    double* indexData(int x,int y);
    double* indexX(int x);
    double* indexY(int y); 
    void setXName(String& title);
    void setYName(String& title);
    String& getXName();
    String& getYName();
  
    double lookup(double xValue,double yValue);
  protected:
    String xName;
    String yName;
  };


  class CSVVector:public CSVData{
  public:
    CSVVector(int _row,int _col);
    virtual CSVDataType type();
    virtual void dump(FILE* file);
    double* indexData(int y,int i);
    double* indexIndependent(int i);
  
    double lookup(int index,double value);
  
    String& getIndependentName();
    Vector<String>& getDataNames();

    void setIndependentName(String& iName);
    void setDependentNames(Vector<String>& dNames);

  protected:
    String independentTitle;
    Vector<String> dataTitle;
  };

}

#endif


