// Copyright Keysight Technologies 2009 - 2015  
#ifndef __TDCM__VECTOR__INCLUDE__FILE__
#define __TDCM__VECTOR__INCLUDE__FILE__
#include <stdio.h>
#include <strings.h>
#include <assert.h>
namespace TDCM{
  template <class T>
    class Container
    {
    public:
      Container(T t){
	this->setData(t);
	this->_next = (NULL);
      }
      void setData(T _data){
	this->_data = _data;
      }
      T data(){
	return this->_data;
      }
      Container<T>* next(){
	return (Container<T>*)this->_next;
      }
    private:
      T _data;
    public:      
      void* _next;
    };
  

  template <class T>
    class Vector{
  public:
    Vector(){
      this->_head = NULL;
      this->_tail = NULL;
      this->_size = 0;
    }
    ~Vector(){
      this->clear();
    }
    
    void prepend(T t){
      if(!this->_head){
	this->_tail = this->_head = new Container<T>(t);
      }
      else{
	Container<T>* temp = new Container<T>(t);
	temp->_next = (this->_head);
	this->_head = temp;
      }
      this->_size++;
    }
    void append(T t){
      this->push_back(t);
    }
    void push_back(T t){
      if(!this->_head){
	this->_tail = this->_head = new Container<T>(t);
      }
      else{
	Container<T>* temp = new Container<T>(t);
	this->_tail->_next = (temp);
	this->_tail = temp;
      }
      this->_size++;
    }
    int size(){
      return this->_size;
    }
    void clear(){
      Container<T>* temp = this->_head;
      Container<T>* temp2;
      while(temp){
	temp2 = temp->next();
	delete temp;
	temp = temp2;
      }
      this->_head = this->_tail = NULL;
      this->_size = 0;
    }
    Container<T>* head(){
      return this->_head;
    }
    Container<T>* tail(){
      return this->_tail;
    }
  private:
    Container<T>* _head;
    Container<T>* _tail;
    int _size;
  };

  
  template <class T> class Queue;	// forward declaration

  template <class T>
      class QueueLink{
      friend class Queue<T>;
  protected:
      QueueLink *prev;
      QueueLink *next;
  public:
      T data;

      QueueLink(void) : prev(NULL), next(NULL)
      {
      }
  };
  
  
  template <class T>
    class Queue{
  public:
    Queue(){
      this->_size = 0;
      this->_head = 0;
      this->_tail = 0;
    }
    ~Queue(){
      clear();
    }
    
    int size(){
      return this->_size;
    }
    bool empty(){
      return (this->_size == 0);
    }
    void clear(){
      QueueLink<T>* t = this->_head;
      QueueLink<T>* t2;
      while(t){
	t2 = t->next;;
	delete t;
	t = t2;
      }
      this->_head = 0;
      this->_tail = 0;
      this->_size = 0;
    }
    void push(T data){
      QueueLink<T>* t = new QueueLink<T>;
      t->data = data;
      t->next = this->_head;

      if (this->_head != NULL)
      {
          this->_head->prev = t;
      }
      this->_head = t;

      if (this->_tail == NULL)
      {
          this->_tail = t;
      }
      this->_size++;
      assert(t->prev == NULL);
    }
    bool pop(T* data){
      QueueLink<T>* t = this->_tail;
      if(t){
        assert(t->next == NULL);
	(*data) = t->data;
        this->_tail = t->prev;
        if (t->prev != NULL)
        {
            t->prev->next = NULL;
        }
        if (this->_head == t)
        {
            this->_head = NULL;
            assert(this->_tail == NULL);
        }
	delete t;
	this->_size--;
	return true;
      }
      return false;
    }
    
  private:
    QueueLink<T> *_head;
    QueueLink<T> *_tail;
    int _size;
  };
}

#endif
