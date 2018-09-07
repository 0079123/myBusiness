# flv.js 降低延迟

```js
plsyer.on(flvjs.Events.STATISTICS_INFO,(statistics)=>{
   // 解决累计延迟问题，如果大于3秒则直接调整到0.5
   if(videoElement.buffered.end(0) - videoElement.currentTime > 3){
       videoElement.currentTime = videoEmelemt.buffered.end(0.5);
   }
});
```

