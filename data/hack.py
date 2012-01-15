import types,sys,time,regsub,string,re

INDENT = '    '

def docs(c,
	 INDENT=INDENT):
    try:
    print 'Object',c,':'
    showdocstring(c.__doc__,1)
	if hasattr(c,'__version__'):
	    print
	    print INDENT+'[Version: %s]' % c.__version__
    except AttributeError:
	pass
    print
    items = []
    try:
	items = c.__dict__.items()
    except AttributeError:
	items = []
    try:
	for m in  c.__methods__:
	    items.append((m,getattr(c,m)))
    except AttributeError:
	pass
    if items:
	items.sort()
	for name,obj in items:
	    if hasattr(obj,'__doc__') and obj.__doc__:
		print INDENT+name,':'
		showdocstring(obj.__doc__,2)

# Helper for docs:

spaces = re.compile('([ ]*)[^ ]')

def showdocstring(doc,level=0,

		  split=regsub.split,INDENT=INDENT,join=string.join,
		  strip=string.strip,expandtabs=string.expandtabs,
		  spaces=spaces):

    try:
	l = split(strip(doc),'\n\|\r\|\r\n')
    except:
	#print '%sno doc string available' % (INDENT*level)
	return
    if len(l) > 1:
	# Try to even out the indents
	indent = sys.maxint
	l = map(expandtabs,l)
	for i in range(1,len(l)):
	    m = spaces.match(l[i])
	    if m:
		sp = m.regs[1][1]
		if sp < indent:
		    indent = sp
	    else:
		# Blank line
		pass
	l = [strip(l[0])] + map(lambda x,indent=indent: x[indent:],l[1:])
    else:
	l = map(strip,l)
    l = map( lambda x,n=level: INDENT*n + x, l)
    s = join(l,'\n')+'\n'
    print s

def info(c):
    print 'Documentation:'
    print '-'*72
    docs(c)
    print
    print 'Attributes, Internals, etc.:'
    print '-'*72
    show(c,2)

def show(c,maxdepth=2,level=0,
	 INDENT=INDENT):
    try:
        r = repr(c)
	if len(r) > 40:
	    r = r[:40]+' ...'
	print '%s%s' % (INDENT*(level),r)
    except:
	return
    level = level + 1
    if level > maxdepth:
	#print
	return
    showobj(c,'__name__',maxdepth,level)
    showobj(c,'__class__',maxdepth,level)
    showseq(c,'__bases__',maxdepth,level)
    showattr(c,'__methods__',maxdepth,level)
    showattr(c,'__members__',maxdepth,level)
    showattr(c,'__attributes__',maxdepth,level)
    showdict(c,'__dict__',maxdepth,level)

def showattr(c,name,maxdepth=1,level=0,
	     INDENT=INDENT):

    """ showattr(c,name) -- for a in c.name: print c.a """

    try:
	items = getattr(c,name)
	items.sort()
    except AttributeError:
	return

    print '%s%s :' % (INDENT*level,name)
    level = level + 1
    if level > maxdepth:
	return

    for x in items:
	try:
	    a = getattr(c,x)
	    r = repr(a)
	except:
	    a = None
	    r = '*exception*'
	if len(r) > 40:
	    r = r[:40]+' ...'
	if level < maxdepth and a is not None:
	    print '%s%s :' % (INDENT*level,x)
	    show(a,maxdepth,level+1)
	else:
	    print '%s%s : %s' % (INDENT*level,x,r)

def showobj(c,name,maxdepth=1,level=0,
	    INDENT=INDENT):

    """ showobj(c,name) -- print object c.name """

    try:
	x = getattr(c,name)
    except AttributeError:
	return

    print '%s%s :' % (INDENT*level,name)
    level = level + 1
    if level > maxdepth:
	return

    show(x,maxdepth,level)

def showseq(c,name,maxdepth=1,level=0,
	    INDENT=INDENT):

    """ showseq(c,name) -- print sequence c.name """

    try:
	items = getattr(c,name)
    except AttributeError:
	return

    print '%s%s :' % (INDENT*level,name)
    level = level + 1
    if level > maxdepth:
	return

    if not items:
	print '%s%s' % (INDENT*level,items)
	return

    for x in items:
	try:
	    r = repr(x)
	except:
	    x = None
	    r = '*exception*'
	if len(r) > 40:
	    r = r[:40]+' ...'
	if level < maxdepth and x is not None:
	    print '%s%s :' % (INDENT*level,r)
	    show(x,maxdepth,level+1)
	else:
	    print '%s%s' % (INDENT*level,r)

def showdict(c,name,maxdepth=1,level=0,
	     INDENT=INDENT):
    
    """ showdict(c,name) -- print c.name.items() """

    try:
	dict = getattr(c,name)
	items = dict.items()
	items.sort()
    except AttributeError:
	return

    print '%s%s :' % (INDENT*level,name)
    level = level + 1
    if level > maxdepth:
	return

    if not items:
	print '%s%s' % (INDENT*level,dict)
	return

    for key,value in items:
	try:
	    k = str(key)
	except:
	    k = '*exception*'
	if len(k) > 40:
	    k = k[:40]+' ...'
	try:
	    v = repr(value)
	except:
	    v = '*exception*'
	    value = None
	if len(v) > 40:
	    v = v[:40]+' ...'
	if level < maxdepth and value is not None:
	    print '%s%s :' % (INDENT*level,k)
	    show(value,maxdepth,level+1)
	else:
	    print '%s%s : %s' % (INDENT*level,k,v)

# End of show helpers

def dis(c):
    if type(c) == types.StringType:
	c = compile(c,'hacking','exec')
    elif type(c) == types.FunctionType:
	c = c.func_code
    elif type(c) == types.MethodType or type(c) == types.UnboundMethodType:
	c = c.im_func.func_code
    import dis
    dis.disco(c)

def clock(code,namespace=None):
    code =  """from time import clock,time;hack_timer=time(),clock()\n"""+\
	    code+\
	    """\nhack_timer=time()-hack_timer[0],clock()-hack_timer[1]; print '%.3fabs %.3fusr sec.' % hack_timer\n"""
    c = compile(code,'hack.clock-code','exec')
    if namespace:
	exec c in namespace
    else:
	import __main__
	exec c in __main__.__dict__
    return ''

class timer:
    utime = 0
    atime = 0

    def start(self,
	      clock=time.clock,time=time.time):
	self.atime = time()
	self.utime = clock()

    def stop(self,
	     clock=time.clock,time=time.time):
	self.utime = clock() - self.utime
	self.atime = time() - self.atime
	return self.utime,self.atime

    def usertime(self,
		 clock=time.clock,time=time.time):
	self.utime = clock() - self.utime
	self.atime = time() - self.atime
	return self.utime

    def abstime(self,
		clock=time.clock,time=time.time):
	self.utime = clock() - self.utime
	self.atime = time() - self.atime
	return self.utime

    def __str__(self):

	return '%0.2fu %0.2fa sec.' % (self.utime,self.atime)

def profile(code,namespace=None):
    code = 'import profile;profile.run("'+code+'")'
    c = compile(code,'profiling','exec')
    if namespace:
	exec c in namespace
    else:
	import __main__
	exec c in __main__.__dict__

def why():
    if hasattr(sys,'last_traceback'):
	tb = sys.last_traceback
	while tb.tb_next != None: tb = tb.tb_next
	frame = tb.tb_frame
	print 'locals() of the last exception:'
	dict(frame.f_locals)
	#return(frame.f_locals)
    else:
	print 'no exception available !'

def dict(d,maxindent=3,indent=0,
	 INDENT=INDENT):
    if hasattr(d,'items'):
	print indent*INDENT+'{'
	if indent < maxindent:
	    items = d.items()
	    items.sort()
	    for k,v in items:
		print indent*INDENT+' ',k,':'
		try:
		    print_here = dict(v,maxindent,indent+1)
		    if print_here:
			s = repr(v)
			if len(s) > 40: s = s[:40] + '...'
			print (indent+1)*INDENT,s
		except: 
		    print (indent+1)*INDENT,'*exception*'
	else:
	    print indent*INDENT,'...'
	print indent*INDENT+'}'
	return None
    else:
	return 'Error: no items-method'

def seq(l,maxindent=10,indent=0):
    try:
	len(l)
	if type(l) == type('') or indent > maxindent: 
	    raise TypeError
	for i in l:
	    try:
		seq(i,maxindent,indent+1)
	    except ValueError: 
		print '*exception*',
	print indent*' |'
	return
    except TypeError:
	print indent*' |',
	s = repr(l)
	if len(s) > 40: s = s[:40] + '...'
	print s

def modules():
    l = sys.modules.items()
    l.sort()
    print 'Loaded modules and packages:'
    for k,v in l:
	p = string.split(k,'.')
	for i in range(len(p)-1):
	    p[i] = '   '
	n = string.join(p,'')
	if v:
	    if hasattr(v,'__path__'):
		print ' %s[%s]' % (string.join(p[:-1],''),p[-1])
	    else:
		print ' %s' % (n)
