### Practical

- default.rmdb contains the next custom implementation
```xml
<usertcl name="merge_all">
    proc OkToMerge {userdata} {
        return 1
    }
</usertcl>
```
- Practical solution is to delete a custom implementation of OkToMerge from the generated default.rmdb

### OkToMerge Concept 

VRM is used to launch simulations whose coverage data is accumulated and recorded in UCDB files.
	
As discussed in Pass/Fail Analysis chapter, the expectation of a UCDB file is communicated to VRM by the presence of a ucdbfile parameter in the Task definition. If such a parameter is defined, VRM uses the value of that parameter as a path (relative to the working directory of the Task, if necessary) to locate the UCDB and read the pass/fail status from the test data record.
	
The OkToMerge procedure returns a true value (1) if the coverage data in the UCDB file should be merged. The decision can be based on any of the data supplied in the userdata array member, the contents of any file, or any other information available from within VRM. If the UCDB file is moved or renamed in the process, the ucdbfile array member should be updated. If the OkToMerge procedure returns a true value, the UCDB file named in the ucdbfile array member (upon return) is automatically added to the nodelete list and the MergeOneUcdb procedure is called. Note that this procedure is only called if the ucdbfile is defined and non-empty so it is perfectly valid to return true in all cases (the default, unless the user overrides this procedure, is to return true in all cases).

```xml
<usertcl name="analyze">
    proc AnalyzePassFail {userdata} {
        upvar $userdata data
	      
        # A non-zero return status constitutes failurecd
        if {!($data(status) == 0)} {
            if {[isDebug]} {
                logDebug "Action '$data(ACTION)' returned failing status (default)"
            }
	                                
            # Clear bogus UCDB status and declare failure
            set data(ucdbstat) {}; return {failed}
	    }
	                                
        # ...absent that, lack of an expected UCDB is an instant pass.
        if {[string equal $data(ucdbfile) {}]} {
            if {[isDebug]} {
                logDebug "No UCDB file defined, assuming '$data(ACTION)' passed (default)"
	        }
	        set data(ucdbstat) {}; return {passed}
	    }
	    #search error in log 
	           
	    set test_dir [file dirname $data(ucdbfile)]  
	    set simulate_log_path $test_dir/simulate.log
	
	    #if it not merge script and it arrived to this point - return pass
	    if {[string equal [file tail $test_dir] "VRMDATA"]} { 
	        set data(ucdbstat) {}; return {passed}
	    }
	    set ch [open $simulate_log_path]
	    set data_log [chan read $ch]
	    chan close $ch

	    set lines [split [string trim $data_log] \n]
	    foreach line $lines {
	        if {!(([string equal "\# UVM_ERROR :    0" $line]) || ([string equal "\# UVM_FATAL :    0" $line]))} { 
	            if {[regexp {error} [string tolower $line]] || [regexp {fatal} [string tolower $line]]}  {
	                set data(ucdbstat) {}; return {failed}
	            }
	        }
	    }
	                   
	    # ...otherwise, convert and return the simulation status from the UCDB file
	        return [ConvertUcdbStatus $data(ucdbstat)]
    }
	</usertcl>
```