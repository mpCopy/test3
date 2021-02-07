// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM__STRING__INCLUDE_FILE__
#define __TDCM__STRING__INCLUDE_FILE__

namespace TDCM{
  class String{
  private:
    void setStringValue(const char* s);
    bool compare(const String& s);
  public:
    char* string;
  public:
    String();
    String(const String& s);
    String(const char* s);
    ~String();
    
    String& operator=(const char* s);
    String& operator=(const String& s);
    bool operator<(const String& rhs){
      return this->compare(rhs);
    }
    void trim();
    void lower();
    bool operator==(const char* s) const;
    bool operator==(const String& s) const;
    void append(const char* s);
    void clear();
    int size() const;
    bool empty() const;
    const char* c_str() const;
    char operator[](const int n) const;
  };
}

#endif
