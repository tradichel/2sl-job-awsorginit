# 2sl-job-awsorginit
Initial code to run in a new AWS account leveraging the 2sl-jobexecframework

Review the execute.sh file in this repository to understand what this job
installs and why.

# Instructions
To run this job:

1. Copy the init.sh file into CloudShell in the default directory.
2. Change the file permissions if neccessary.

```
chmod 700 init.sh
```

3. Execute the script:

```
./init.sh
```

If the script has to install an updated version of buildx,
then you will need to restart CloudShell and run the script again.

 > Click Actions on top right of CloudShell. Then
 > scroll down and choose Restart AWS CloudShell

That is because the install will use up all the "space on the device"
and you will get an error if you try to run everything at once.

You can view the remaining space by typing this command:

```  
df
```

Once you restart CloudShell, space is cleared and you can run 
the rest of the script.

# About the 2nd Sight Lab Job Execution Framework

For more information please read the readme in this repository:

[2sl-jobexecframework](https://github.com/tradichel/2sl-jobexecframework/tree/main)
