FROM ghcr.io/battleofthebots/botb-base-image:latest 

#jre folder in https://jdk.java.net/java-se-ri/8-MR5
COPY jre-se-8u43-ri.tar.xz /tmp
RUN mkdir /data
RUN chown -R user:user /data
WORKDIR /opt
RUN tar -Jxf /tmp/jre-se-8u43-ri.tar.xz

WORKDIR /data
RUN wget https://github.com/itzg/mc-monitor/releases/download/0.12.1/mc-monitor_0.12.1_linux_amd64.tar.gz -O - | tar -xz mc-monitor && \
    curl https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar --output server.jar && \
    echo "eula=true" > eula.txt && \
    echo -e 'allow-nether=false\ndifficulty=peaceful\ngenerate-structures=false\nlevel-type=flat\nonline-mode=false\nsimulation-distance=3\nspawn-animals=false\nspawn-monsters=false\nspawn-npcs=false\nview-distance=3' > server.properties
USER user
CMD /opt/jre-se-8u43-ri/bin/java -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Xmx512M -Xms512M -Dlog4j2.formatMsgNoLookups=true -Dcom.sun.jndi.ldap.object.trustURLCodebase=true, -jar /data/server.jar 
HEALTHCHECK --interval=5s --timeout=5s --start-period=5s --retries=3 CMD [ "./mc-monitor", "status" ]