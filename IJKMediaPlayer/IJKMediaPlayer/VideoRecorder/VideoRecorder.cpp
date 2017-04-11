//
//  VideoRecorder.cpp
//  IJKMediaPlayer
//
//  Created by ning on 16/4/30.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#define IJK_LOG_UNKNOWN     0
#define IJK_LOG_DEFAULT     1

#define IJK_LOG_VERBOSE     2
#define IJK_LOG_DEBUG       3
#define IJK_LOG_INFO        4
#define IJK_LOG_WARN        5
#define IJK_LOG_ERROR       6
#define IJK_LOG_FATAL       7
#define IJK_LOG_SILENT      8

#define VLOG(level, TAG, ...)    ((void)vprintf(__VA_ARGS__))
#define ALOG(level, TAG, ...)    ((void)printf(__VA_ARGS__))


#define IJK_LOG_TAG "VideoRecorder"

#define VLOGV(...)  VLOG(IJK_LOG_VERBOSE,   IJK_LOG_TAG, __VA_ARGS__)
#define VLOGD(...)  VLOG(IJK_LOG_DEBUG,     IJK_LOG_TAG, __VA_ARGS__)
#define VLOGI(...)  VLOG(IJK_LOG_INFO,      IJK_LOG_TAG, __VA_ARGS__)
#define VLOGW(...)  VLOG(IJK_LOG_WARN,      IJK_LOG_TAG, __VA_ARGS__)
#define VLOGE(...)  VLOG(IJK_LOG_ERROR,     IJK_LOG_TAG, __VA_ARGS__)

#define ALOGV(...)  ALOG(IJK_LOG_VERBOSE,   IJK_LOG_TAG, __VA_ARGS__)
#define ALOGD(...)  ALOG(IJK_LOG_DEBUG,     IJK_LOG_TAG, __VA_ARGS__)
#define ALOGI(...)  ALOG(IJK_LOG_INFO,      IJK_LOG_TAG, __VA_ARGS__)
#define ALOGW(...)  ALOG(IJK_LOG_WARN,      IJK_LOG_TAG, __VA_ARGS__)
#define ALOGE(...)  ALOG(IJK_LOG_ERROR,     IJK_LOG_TAG, __VA_ARGS__)
#define LOG_ALWAYS_FATAL(...)   do { ALOGE(__VA_ARGS__); exit(1); } while (0)

#include "VideoRecorder.hpp"
#include "Lock.hpp"

extern "C" {
#include "libavutil/avassert.h"
#include "libavutil/opt.h"
#include "libavutil/audio_fifo.h"
#include "libavutil/mathematics.h"
#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
#include "libavutil/time.h"
    
#include "libavfilter/avfiltergraph.h"
#include "libavfilter/buffersink.h"
#include "libavfilter/buffersrc.h"
#include "libavutil/avutil.h"
#include "libavutil/pixdesc.h"
}

namespace AVR {
    
    class VideoRecorderImpl : public VideoRecorder {
    public:
        VideoRecorderImpl();
        
        ~VideoRecorderImpl();
        
        bool SetVideoOptions(VideoFrameFormat fmt, const char *overlay, int width, int height, int srcHight,
                             int cameraSelection, unsigned long bitrate);
        
        bool SetVideoOptionsInfo(int srcHight, int cameraSelection);
        
        bool SetAudioOptions(AudioSampleFormat fmt, int channels, unsigned long samplerate,
                             unsigned long bitrate);
        
        bool Open(const char *mp4file, bool hasAudio, bool dbg);
        
        bool Close();
        
        bool Start();
        
        void SupplyVideoFrame(const void *frame, unsigned long timestamp);
        
        void SupplyAudioSamples(void *samples, unsigned long numSamples);
        
    private:
        
        AVStream *add_audio_stream(enum AVCodecID codec_id);
        
        void open_audio();
        
        void write_audio_frame(AVStream *st);
        
        AVStream *add_video_stream(enum AVCodecID codec_id);
        
        void open_video();
        
        void write_video_frame(AVStream *st);
        
        int init_filters(const char *filters_descr);
        
        // audio related vars
        AVStream *audio_st;
        
        AVFrame *audio_frame;
        uint8_t **src_samples_data;
        int src_samples_linesize;
        int src_nb_samples;
        
        int max_dst_nb_samples;
        uint8_t **dst_samples_data;
        int dst_samples_linesize;
        int dst_samples_size;
        int audio_samples_count;
        int video_samples_count;
        
        uint8_t *YUV420spCrop(const uint8_t *data, int imageW, int imageH, int newImageH);
        
        uint8_t *rotateYUV420Degree180(const uint8_t *data, int imageWidth, int imageHeight);
        
        uint8_t *YUV420spRotate90(const uint8_t *data, int imageWidth, int imageHeight);
        
        uint8_t *YUV420spRotate90(const uint8_t *src, int srcWidth, int height, int mode);
        
        uint8_t *YUV420spRotateNegative90(const uint8_t *data, int imageWidth, int imageHeight);
       
        
        
        
        struct SwrContext *swr_ctx;
        
        struct AVAudioFifo *av_fifo;
        
        unsigned long audio_input_leftover_samples;
        
        int audio_channels;
        // number of channels (2)
        unsigned long audio_bit_rate;
        // codec's output bitrate
        unsigned long audio_sample_rate;
        // number of samples per second
        int audio_sample_size;
        // size of each sample in bytes (16-bit = 2)
        AVSampleFormat audio_sample_format;
        
        CMutex g_Lock;
        
        
        // video related vars
        uint8_t *video_outbuf;
        int video_outbuf_size;
        AVStream *video_st;
        
        const char *video_overlay;
        int video_width;
        int video_height;
        int video_srcHight;
        int video_cameraSelection;
        unsigned long video_bitrate;
        AVPixelFormat video_pixfmt;
        AVFrame *picture;// video frame after being converted to x264-friendly YUV420P
        AVFrame *filter_picture;// video frame after being converted to x264-friendly YUV420P
        
        AVPicture src_picture, dst_picture;
        
        
        SwsContext *img_convert_ctx;
        
        bool isRecordVideo = false;
        bool isRecording = false;
        
        // common
        AVFormatContext *oc;
        
        AVCodec *audio_codec, *video_codec;
        
        const char *filter_descr = "lutyuv='u=128:v=128'";
        AVCodecContext *dec_ctx;
        AVFilterContext *buffersink_ctx;
        AVFilterContext *buffersrc_ctx;
        AVFilterGraph *filter_graph;
    };
    
    VideoRecorder::VideoRecorder() {
        
    }
    
    VideoRecorder::~VideoRecorder() {
        
    }
    
    VideoRecorderImpl::VideoRecorderImpl() {
        ALOGV("~VideoRecorderImpl()");
        audio_st = NULL;
        audio_frame = NULL;
        audio_input_leftover_samples = 0;
        swr_ctx = NULL;
        av_fifo = NULL;
        isRecordVideo = false;
        isRecording = false;
        video_outbuf = NULL;
        video_st = NULL;
        audio_samples_count = 0;
        video_samples_count = 0;
        picture = NULL;
        filter_picture = NULL;
        img_convert_ctx = NULL;
        oc = NULL;
        
    }
    
    VideoRecorderImpl::~VideoRecorderImpl() {
        ALOGV("~VideoRecorderImpl()");
        
    }
    
    static void avlog_cb(void *, int level, const char *szFmt, va_list varg) {
        //do nothing...
    }
    
    bool VideoRecorderImpl::Open(const char *mp4file, bool hasAudio, bool dbg) {
        av_register_all();
        avcodec_register_all();
        avfilter_register_all();
        av_log_set_callback(avlog_cb);
        avformat_alloc_output_context2(&oc, NULL, NULL, mp4file);
        if (!oc) {
            ALOGE("could not deduce output format from file extension\n");
            return false;
        }
        
        video_st = add_video_stream(AV_CODEC_ID_H264);
        
        if (hasAudio)
            audio_st = add_audio_stream(AV_CODEC_ID_AAC);
        
        if (dbg)
            av_dump_format(oc, 0, mp4file, 1);
        
        open_video();
        
        if (hasAudio)
            open_audio();
        
        ALOGE("init filters start");
        
//        if(video_cameraSelection == 0) {
//            //后置摄像头
//            filter_descr = "transpose=1[scl];[scl]crop=480:480";
//        } else {
//            // 前置摄像头
//            filter_descr = "transpose=1[scl];[scl]hflip[sc2];[sc2]crop=480:480";
//        }
//        
//        init_filters(filter_descr);
//        ALOGE("init filters end");
        
        char args[512];
        char argsAll[512];
        
        int cropHeight = (video_srcHight - video_height) / 2;
        
        if(video_cameraSelection == 0) {
            //后置摄像头
            snprintf(args, sizeof(args),"transpose=1[scl];[scl]crop=%d:%d:0:%d", video_width, video_height, cropHeight);
            //filter_descr = "transpose=1[scl];[scl]crop=480:480";
        } else {
            // 前置摄像头
            snprintf(args, sizeof(args),"transpose=2[scl];[scl]hflip[sc2];[sc2]crop=%d:%d:0:%d", video_width, video_height, cropHeight);
            //filter_descr = "transpose=2[scl];[scl]hflip[sc2];[sc2]crop=480:480";
        }
        
        if (strcmp(video_overlay, "null") == 0) {
            ALOGE("filters : %s", args);
            init_filters(args);
            ALOGE("init filters end");
        } else {
            snprintf(argsAll, sizeof(argsAll),"movie=%s [watermark];[in]%s[trans]; [trans][watermark] overlay=0:0 [out]",
                     video_overlay, args);
            ALOGE("filters argsAll : %s", argsAll);
            init_filters(argsAll);
            ALOGE("init filters end");
        }
        
        
        
        
        
        
        if (avio_open(&oc->pb, mp4file, AVIO_FLAG_WRITE) < 0) {
            ALOGE("could not open '%s'\n", mp4file);
            return false;
        }
        AVDictionary *options = NULL;
        int ret = avformat_write_header(oc, &options);
        if (ret < 0) {
            ALOGE("could not avformat_write_header '%s'\n", mp4file);
            av_dict_free(&options);
            return false;
        }
        av_dict_free(&options);
        isRecording = true;
        return true;
    }
    
    AVStream *VideoRecorderImpl::add_audio_stream(enum AVCodecID codec_id) {
        AVCodecContext *audioContext;
        AVStream *st;
        
        audio_codec = avcodec_find_encoder(codec_id);
        audio_codec = avcodec_find_encoder_by_name("libfaac");
        if (!audio_codec) {
            ALOGE("audio_codec not found\n");
            return NULL;
        }
        
        st = avformat_new_stream(oc, audio_codec);
        if (!st) {
            ALOGE("could not alloc stream\n");
            return NULL;
        }
        st->id = oc->nb_streams - 1;
        audioContext = st->codec;
        //        avcodec_get_context_defaults3(audioContext, audio_codec);
        //        c = avcodec_alloc_context3(audio_codec);
        audioContext->strict_std_compliance = FF_COMPLIANCE_UNOFFICIAL; // for native aac support
        audioContext->codec_id = codec_id;
        audioContext->codec_type = AVMEDIA_TYPE_AUDIO;
        audioContext->sample_fmt = audio_sample_format;
        audioContext->bit_rate = audio_bit_rate;
        audioContext->sample_rate = (int)audio_sample_rate;
        audioContext->channels = audio_channels;
        audioContext->channel_layout = AV_CH_LAYOUT_MONO;
        audioContext->profile = FF_PROFILE_AAC_LOW;
        if (oc->oformat->flags & AVFMT_GLOBALHEADER)
            audioContext->flags |= CODEC_FLAG_GLOBAL_HEADER;
        
        ALOGE("add_audio_stream c->channels : %d \n", audioContext->channels);
        
        return st;
    }
    
    
    /**************************************************************/
    /* audio output */
    
    
    void VideoRecorderImpl::open_audio() {
        
        AVCodecContext *audioOpenContext;
        int ret;
        
        audioOpenContext = audio_st->codec;
        /* allocate and init a re-usable frame */
        audio_frame = av_frame_alloc();
        if (!audio_frame) {
            ALOGE("Could not allocate audio frame\n");
        }
        
        /* open it */
        AVDictionary *opts = NULL;
        av_dict_set(&opts, "strict", "experimental", 0);
        ret = avcodec_open2(audioOpenContext, audio_codec, &opts);
        av_dict_free(&opts);
        if (ret < 0) {
            ALOGE("Could not open audio codec: %d \n", ret);
            //exit(1);
        }
        
        
        src_nb_samples =
        audioOpenContext->codec->capabilities & CODEC_CAP_VARIABLE_FRAME_SIZE ?
        10000 : audioOpenContext->frame_size;
        
        ALOGE("src_nb_samples : %d \n", src_nb_samples);
        ALOGE("c->channels : %d \n", audioOpenContext->channels);
        
        ret = av_samples_alloc_array_and_samples(&src_samples_data,
                                                 &src_samples_linesize, audioOpenContext->channels, src_nb_samples,
                                                 AV_SAMPLE_FMT_S16, 0);
        if (ret < 0) {
            ALOGE("Could not allocate source samples\n");
            //exit(1);
        }
        
        av_fifo = av_audio_fifo_alloc(audioOpenContext->sample_fmt, audioOpenContext->channels, audioOpenContext->frame_size);
        
        /* compute the number of converted samples: buffering is avoided
         * ensuring that the output buffer will contain at least all the
         * converted input samples */
        max_dst_nb_samples = src_nb_samples;
        
        /* create resampler context */
        if (audioOpenContext->sample_fmt != AV_SAMPLE_FMT_S16) {
            swr_ctx = swr_alloc();
            if (!swr_ctx) {
                fprintf(stderr, "Could not allocate resampler context\n");
                //exit(1);
            }
            
            /* set options */
            av_opt_set_int(swr_ctx, "in_channel_count", audioOpenContext->channels, 0);
            av_opt_set_int(swr_ctx, "in_sample_rate", audioOpenContext->sample_rate, 0);
            av_opt_set_sample_fmt(swr_ctx, "in_sample_fmt", AV_SAMPLE_FMT_S16, 0);
            av_opt_set_int(swr_ctx, "out_channel_count", audioOpenContext->channels, 0);
            av_opt_set_int(swr_ctx, "out_sample_rate", audioOpenContext->sample_rate, 0);
            av_opt_set_sample_fmt(swr_ctx, "out_sample_fmt", audioOpenContext->sample_fmt, 0);
            
            /* initialize the resampling context */
            if ((ret = swr_init(swr_ctx)) < 0) {
                ALOGE("Failed to initialize the resampling context\n");
                //exit(1);
            }
            
            ret = av_samples_alloc_array_and_samples(&dst_samples_data,
                                                     &dst_samples_linesize, audioOpenContext->channels,
                                                     max_dst_nb_samples,
                                                     audioOpenContext->sample_fmt, 0);
            if (ret < 0) {
                ALOGE("Could not allocate destination samples\n");
                //exit(1);
            }
        } else {
            dst_samples_data = src_samples_data;
        }
        dst_samples_size = av_samples_get_buffer_size(NULL, audioOpenContext->channels,
                                                      max_dst_nb_samples, audioOpenContext->sample_fmt, 0);
    }
    
    AVStream *VideoRecorderImpl::add_video_stream(enum AVCodecID codec_id) {
        AVCodecContext *videoContext;
        AVStream *st;
        
        video_codec = avcodec_find_encoder(codec_id);
        if (!video_codec) {
            ALOGE("video_codec not found\n");
            return NULL;
        }
        
        st = avformat_new_stream(oc, video_codec);
        if (!st) {
            ALOGE("could not alloc stream\n");
            return NULL;
        }
        st->id = oc->nb_streams - 1;
        videoContext = st->codec;
        //        c = avcodec_alloc_context3(video_codec);
        //编码器的ID号，这里我们自行指定为264编码器，实际上也可以根据video_st里的codecID 参数赋值
        videoContext->codec_id = codec_id;
        //编码器编码的数据类型
        videoContext->codec_type = AVMEDIA_TYPE_VIDEO;
        
        /* put sample parameters */
        videoContext->rc_min_rate = video_bitrate;
        videoContext->rc_max_rate = video_bitrate;
        
        //目标的码率，即采样的码率；显然，采样码率越大，视频大小越大
        videoContext->bit_rate = video_bitrate;
        //固定允许的码率误差，数值越大，视频越小
        videoContext->bit_rate_tolerance = 4000000;
        videoContext->width = video_width;
        videoContext->height = video_height;
        
        //帧率的基本单位，我们用分数来表示，
        //用分数来表示的原因是，有很多视频的帧率是带小数的eg：NTSC 使用的帧率是29.97
        
        //    http://blog.csdn.net/qq_32430349/article/details/49818095
        //    time_base = 1/90000(单位：秒).
        //    time_base的用法：举个例子，在AVFrame中有成员pkt_pts
        //    PTS copied from the AVPacket that was decoded to produce this frame.即从packet包中解出的pts。（见ffmpeg重要结构体之AVFrame）
        //    某一帧图像的pkt_pts为2965399930，下一帧图像的pkt_pts为2965403530，两者之差为3600，其单位就是time_base。
        //    3600*（1/90000） = 0.04秒，正好是一个帧率为25的视频的两帧间的时间间隔。
        //    AVRational avg_frame_rate：帧率的分数表示。比如24000/1001.
        
        //	c->time_base.num = 1;
        //	c->time_base.den = 90000; /* 15 images/s */
        videoContext->time_base = (AVRational) {1, 90000};
        //像素的格式，也就是说采用什么样的色彩空间来表明一个像素点
        videoContext->pix_fmt = AV_PIX_FMT_YUV420P; // we convert everything to PIX_FMT_YUV420P
        
        // http://stackoverflow.com/questions/3553003/encoding-h-264-with-libavcodec-x264
        
        /*x264 ultrafast preset*/
        videoContext->delay = 0;
        videoContext->thread_count = 0;
        //两个非B帧之间允许出现多少个B帧数
        //设置0表示不使用B帧
        //b 帧越多，图片越小
        videoContext->max_b_frames = 0; // bframes = 0
        //	//运动估计
        //	c->pre_me = 2;
        videoContext->me_method = ME_HEX; // me = dia !!!
        videoContext->refs = 1; // ref = 1
        //	c->me_cmp|= 1;
        videoContext->scenechange_threshold = 40;
        videoContext->trellis = 0; // trellis = 0
        //	c->coder_type = 0;
        //	c->me_subpel_quality = 10;
        //	c->me_range = 16;
        //每250帧插入1个I帧，I帧越少，视频越小  250
        videoContext->gop_size = 12;
        //	c->keyint_min = 25;
        //	c->trellis=0;
        videoContext->i_quant_factor = 0.71;
        videoContext->b_frame_strategy = 0;
        //	c->qcompress = 0.6;
        //设置最小和最大拉格朗日乘数
        //拉格朗日乘数 是统计学用来检测瞬间平均值的一种方法
        //	c->lmin = 1;
        //	c->lmax = 5;
        //最大和最小量化系数
        videoContext->qmin = 10;
        videoContext->qmax = 30;
        //因为我们的量化系数q是在qmin和qmax之间浮动的，
        //qblur表示这种浮动变化的变化程度，取值范围0.0～1.0，取0表示不削减
        //	c->qblur = 0.0;
        //	c->max_qdiff = 4;
        videoContext->flags |= CODEC_FLAG_LOOP_FILTER;
        videoContext->level = 30;
        videoContext->profile = FF_PROFILE_H264_BASELINE;
        
        if (oc->oformat->flags & AVFMT_GLOBALHEADER)
            videoContext->flags |= CODEC_FLAG_GLOBAL_HEADER;
        
        av_opt_set(videoContext->priv_data, "subq", "6", 0);
        av_opt_set(videoContext->priv_data, "crf", "20.0", 0);
        av_opt_set(videoContext->priv_data, "weighted_p_pred", "0", 0);
        av_opt_set(videoContext->priv_data, "preset", "ultrafast", 0);
        av_opt_set(videoContext->priv_data, "tune", "zerolatency", 0);
        av_opt_set(videoContext->priv_data, "x264opts", "rc-lookahead=0", 0);
        av_opt_set(videoContext->priv_data, "x264opts", "sync_lookahead=0", 0);
        av_opt_set(videoContext->priv_data, "sync_lookahead", "0", 0);
        
        
        return st;
    }
    
    void VideoRecorderImpl::open_video() {
        AVCodecContext *videoOpenContext;
        AVDictionary *opts = NULL;
        
        if (!video_st) {
            ALOGE("tried to open_video without a valid video_st (add_video_stream must have failed)\n");
            return;
        }
        
        videoOpenContext = video_st->codec;
        
        av_dict_set(&opts, "profile", "baseline", 0);
        if (avcodec_open2(videoOpenContext, video_codec, &opts) < 0) {
            ALOGE("could not open codec\n");
            return;
        }
        av_dict_free(&opts);
        
        /* allocate and init a re-usable frame */
        picture = av_frame_alloc();
        filter_picture = av_frame_alloc();
        if (!picture) {
            ALOGE("Could not allocate video frame\n");
            return;
        }
        picture->format = videoOpenContext->pix_fmt;
        picture->width = video_srcHight;
        picture->height = video_width;
        
        /* Allocate the encoded raw picture. */
        if (avpicture_alloc(&dst_picture, videoOpenContext->pix_fmt, video_srcHight, video_width) < 0) {
            ALOGE("Could not allocate picture\n");
            return;
        }
        
        /* If the output format is not YUV420P, then a temporary YUV420P
         * picture is needed too. It is then converted to the required
         * output format. */
        if (videoOpenContext->pix_fmt != AV_PIX_FMT_YUV420P) {
            if (avpicture_alloc(&src_picture, AV_PIX_FMT_YUV420P, video_srcHight, video_width) < 0) {
                ALOGE("Could not allocate temporary picture\n");
            }
        }
        
        /* copy data and linesize picture pointers to frame */
        *((AVPicture *) picture) = dst_picture;
        
        
        img_convert_ctx = sws_getContext(video_srcHight, video_width, video_pixfmt, video_srcHight,
                                         video_width, AV_PIX_FMT_YUV420P, /*SWS_BICUBIC*/
                                         SWS_FAST_BILINEAR, NULL, NULL, NULL);
        if (img_convert_ctx == NULL) {
            ALOGE("Could not initialize sws context\n");
            return;
        }
    }
    
    int write_frame(AVFormatContext *fmt_ctx, const AVRational *time_base, AVStream *st,
                    AVPacket *pkt) {
        /* rescale output packet timestamp values from codec to stream timebase */
        pkt->pts = av_rescale_q_rnd(pkt->pts, *time_base, st->time_base,
                                    (AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));
        pkt->dts = av_rescale_q_rnd(pkt->dts, *time_base, st->time_base,
                                    (AVRounding)(AV_ROUND_NEAR_INF | AV_ROUND_PASS_MINMAX));
        pkt->duration = av_rescale_q(pkt->duration, *time_base, st->time_base);
        pkt->stream_index = st->index;
        
        /* Write the compressed frame to the media file. */
        av_interleaved_write_frame(fmt_ctx, pkt);
        return 0;
    }
    
    int interleaved_write_frame(AVFormatContext *oc, AVStream *st, int audio_video) {
        int ret = 0;
        AVCodecContext *interleavedContext;
        AVPacket pkt = {0};
        interleavedContext = st->codec;
        int got_output = 1;
        while (got_output) {
            av_init_packet(&pkt);
            pkt.data = NULL;
            pkt.size = 0;
            ret = audio_video == 1 ? avcodec_encode_audio2(interleavedContext, &pkt, NULL, &got_output)
            : avcodec_encode_video2(interleavedContext, &pkt, NULL, &got_output);
            if (ret < 0) {
                ALOGE("Error encoding frame\n");
                return 0;
            }
            if (got_output) {
                ALOGV("SupplyVideoFrame got_packet is %d \n", got_output);
                pkt.pts = av_rescale_q(pkt.pts, interleavedContext->time_base, st->time_base);
                pkt.dts = av_rescale_q(pkt.dts, interleavedContext->time_base, st->time_base);
                pkt.duration = av_rescale_q(pkt.duration, interleavedContext->time_base, st->time_base);
                av_interleaved_write_frame(oc, &pkt);
                av_packet_unref(&pkt);
            }
        }
        return ret;
    }
    
    
    bool VideoRecorderImpl::Close() {
        isRecordVideo = false;
        isRecording = false;
        if (oc) {
            if (audio_st) {
                ALOGV("recorder closed audio");
                AVCodecContext *audioCloseContext;
                AVPacket pkt = {0}; // data and size must be 0;
                int got_packet, ret, dst_nb_samples;
                
                av_init_packet(&pkt);
                audioCloseContext = audio_st->codec;
                ALOGV("recorder closed 1111\n");
                while (av_fifo && av_audio_fifo_size(av_fifo) >= audioCloseContext->frame_size) {
                    ALOGV("recorder closed 11111\n");
                    av_audio_fifo_read(av_fifo, (void **) src_samples_data, audioCloseContext->frame_size);
                    /* convert samples from native format to destination codec format, using the resampler */
                    dst_nb_samples = src_nb_samples;
                    audio_frame->nb_samples = dst_nb_samples;
                    //(AVRational) {1, c->sample_rate}
                    audio_frame->pts = av_rescale_q(audio_samples_count,
                                                    audio_st->time_base, audioCloseContext->time_base);
                    avcodec_fill_audio_frame(audio_frame, audioCloseContext->channels,
                                             audioCloseContext->sample_fmt, dst_samples_data[0], dst_samples_size,
                                             0);
                    audio_samples_count += dst_nb_samples;
                    
                    ret = avcodec_encode_audio2(audioCloseContext, &pkt, audio_frame, &got_packet);
                    if (ret < 0) {
                        ALOGE("Error encoding audio frame \n");
                        break;
                    }
                    if (got_packet) {
                        ALOGV("recorder closed 111111\n");
                        if (write_frame(oc, &audioCloseContext->time_base, audio_st, &pkt)
                            < 0) {
                            ALOGE("Error while writing audio frame: %d\n", ret);
                        }
                        av_packet_unref(&pkt);
                    }
                }
                
                ALOGV("recorder closed 11111111");
                av_audio_fifo_free(av_fifo);
                
            }
            if (video_st) {
                interleaved_write_frame(oc, video_st, 2);
                ALOGV("recorder closed 2");
            }
            
            int ret = av_write_trailer(oc);
            
            if (ret < 0) {
                ALOGE("could not av_write_trailer \n");
                return false;
            }
            if (audio_st) {
                avcodec_close(audio_st->codec);
                if (dst_samples_data != src_samples_data) {
                    av_free(dst_samples_data[0]);
                    av_free(dst_samples_data);
                }
                
                
                if (src_samples_data) {
                    if (src_samples_data[0])
                        av_free(src_samples_data[0]);
                    av_free(src_samples_data);
                }
                
                av_frame_free(&audio_frame);
            }
            
            
            avcodec_close(video_st->codec);
            av_frame_free(&picture);
            av_frame_free(&filter_picture);
            
            if (img_convert_ctx) {
                sws_freeContext(img_convert_ctx);
            }
            avio_close(oc->pb);
            avformat_free_context(oc);
            avfilter_graph_free(&filter_graph);
        }
        audio_samples_count = 0;
        video_samples_count = 0;
        return true;
    }
    
    bool VideoRecorderImpl::SetVideoOptions(VideoFrameFormat fmt, const char *overlay, int width, int height, int srcHight,
                                            int cameraSelection, unsigned long bitrate) {
        switch (fmt) {
            case VideoFrameFormatYUV420P:
                video_pixfmt = AV_PIX_FMT_YUV420P;
                break;
            case VideoFrameFormatNV12:
                video_pixfmt = AV_PIX_FMT_NV12;
                break;
            case VideoFrameFormatNV21:
                video_pixfmt = AV_PIX_FMT_NV21;
                break;
            case VideoFrameFormatRGB24:
                video_pixfmt = AV_PIX_FMT_RGB24;
                break;
            case VideoFrameFormatBGR24:
                video_pixfmt = AV_PIX_FMT_BGR24;
                break;
            case VideoFrameFormatARGB:
                video_pixfmt = AV_PIX_FMT_ARGB;
                break;
            case VideoFrameFormatRGBA:
                video_pixfmt = AV_PIX_FMT_RGBA;
                break;
            case VideoFrameFormatABGR:
                video_pixfmt = AV_PIX_FMT_ABGR;
                break;
            case VideoFrameFormatBGRA:
                video_pixfmt = AV_PIX_FMT_BGRA;
                break;
            case VideoFrameFormatRGB565LE:
                video_pixfmt = AV_PIX_FMT_RGB565LE;
                break;
            case VideoFrameFormatRGB565BE:
                video_pixfmt = AV_PIX_FMT_RGB565BE;
                break;
            case VideoFrameFormatBGR565LE:
                video_pixfmt = AV_PIX_FMT_BGR565LE;
                break;
            case VideoFrameFormatBGR565BE:
                video_pixfmt = AV_PIX_FMT_BGR565BE;
                break;
            default:
                ALOGE("Unknown frame format passed to SetVideoOptions!\n");
                return false;
        }
        video_overlay = overlay;
        video_width = width;
        video_height = height;
        video_srcHight = srcHight;
        video_cameraSelection = cameraSelection;
        video_bitrate = bitrate;
        return true;
    }
    
    bool VideoRecorderImpl::SetVideoOptionsInfo(int srcHight, int cameraSelection) {
        
        video_srcHight = srcHight;
        video_cameraSelection = cameraSelection;
        return true;
        
    }
    
    bool VideoRecorderImpl::SetAudioOptions(AudioSampleFormat fmt, int channels,
                                            unsigned long samplerate, unsigned long bitrate) {
        switch (fmt) {
            case AudioSampleFormatU8:
                audio_sample_format = AV_SAMPLE_FMT_U8;
                audio_sample_size = 1;
                break;
            case AudioSampleFormatS16:
                audio_sample_format = AV_SAMPLE_FMT_S16;
                audio_sample_size = 2;
                break;
            case AudioSampleFormatS32:
                audio_sample_format = AV_SAMPLE_FMT_S32;
                audio_sample_size = 4;
                break;
            case AudioSampleFormatFLTP:
                audio_sample_format = AV_SAMPLE_FMT_FLTP;
                audio_sample_size = 4;
                break;
            case AudioSampleFormatDBL:
                audio_sample_format = AV_SAMPLE_FMT_DBL;
                audio_sample_size = 8;
                break;
            default:
                ALOGE("Unknown sample format passed to SetAudioOptions!\n");
                return false;
        }
        audio_channels = channels;
        audio_bit_rate = bitrate;
        audio_sample_rate = samplerate;
        return true;
    }
    
    bool VideoRecorderImpl::Start() {
        return true;
    }
    
    
    void VideoRecorderImpl::SupplyAudioSamples(void *sampleData,
                                               unsigned long numSamples) {
        // check whether there is any audio stream (hasAudio=true)
        if (!isRecording)
            return;
        
        if (audio_st == NULL) {
            ALOGE("tried to supply an audio frame when no audio stream was present\n");
            return;
        }
        CMyLock lock(g_Lock);
        AVCodecContext *audioSupplayContext;
        AVPacket pkt = {0}; // data and size must be 0;
        int got_packet, ret, dst_nb_samples;
        
        av_init_packet(&pkt);
        audioSupplayContext = audio_st->codec;
        if (!av_fifo)
            return;
        av_audio_fifo_write(av_fifo, &sampleData, (int)numSamples);
        if (!isRecordVideo)
            return;
        
        
        
        while (av_audio_fifo_size(av_fifo) >= audioSupplayContext->frame_size) {
            if (!isRecordVideo || !isRecording)
                return;
            av_audio_fifo_read(av_fifo, (void **) src_samples_data, audioSupplayContext->frame_size);
            if (swr_ctx) {
                /* compute destination number of samples */
                dst_nb_samples = av_rescale_rnd(
                                                swr_get_delay(swr_ctx, audioSupplayContext->sample_rate) + src_nb_samples,
                                                audioSupplayContext->sample_rate, audioSupplayContext->sample_rate, AV_ROUND_UP);
                if (dst_nb_samples > max_dst_nb_samples) {
                    av_free(dst_samples_data[0]);
                    ret = av_samples_alloc(dst_samples_data, &dst_samples_linesize, audioSupplayContext->channels,
                                           dst_nb_samples, audioSupplayContext->sample_fmt, 0);
                    if (ret < 0)
                        return;
                    max_dst_nb_samples = dst_nb_samples;
                    dst_samples_size = av_samples_get_buffer_size(NULL, audioSupplayContext->channels, dst_nb_samples,
                                                                  audioSupplayContext->sample_fmt, 0);
                }
                /* convert to destination format */
                ret = swr_convert(swr_ctx,
                                  dst_samples_data, dst_nb_samples,
                                  (const uint8_t **) src_samples_data, src_nb_samples);
                if (ret < 0) {
                    ALOGE("Error while converting\n");
                    return;
                }
            } else {
                dst_nb_samples = src_nb_samples;
            }
            
            
            if (audio_samples_count < 0)
                audio_samples_count = 0;
            audio_frame->nb_samples = dst_nb_samples;
            if (audioSupplayContext->coded_frame && audioSupplayContext->coded_frame->pts != AV_NOPTS_VALUE)
                audio_frame->pts = av_rescale_q(audioSupplayContext->coded_frame->pts, audioSupplayContext->time_base,
                                                audio_st->time_base);
            avcodec_fill_audio_frame(audio_frame, audioSupplayContext->channels, audioSupplayContext->sample_fmt,
                                     dst_samples_data[0], dst_samples_size, 0);
            
            audio_samples_count += dst_nb_samples;
            ret = avcodec_encode_audio2(audioSupplayContext, &pkt, audio_frame, &got_packet);
            if (ret < 0) {
                ALOGE("Error encoding audio frame: %d\n", ret);
                return;
            }
            if (got_packet) {
                if (write_frame(oc, &audioSupplayContext->time_base, audio_st, &pkt) < 0) {
                    ALOGE("Error while writing audio frame: %d\n", ret);
                }
                av_packet_unref(&pkt);
            }
            
        }
        
    }
    
    uint8_t *VideoRecorderImpl::YUV420spCrop(const uint8_t *data, int imageW, int imageH,
                                             int newImageH) {
        ALOGE("YUV420spCrop imageW = %d, imageH = %d, newImageH = %d", imageW, imageH, newImageH);
        int cropH;
        int i, j, count, tmp;
        uint8_t *yuv = new uint8_t[imageW * imageH * 3 / 2];
        cropH = 0;
        
        count = 0;
        for (j = cropH; j < cropH + newImageH; j++) {
            for (i = 0; i < imageW; i++) {
                yuv[count++] = data[j * imageW + i];
            }
        }
        
        // Cr Cb
        tmp = imageH + cropH / 2;
        for (j = tmp; j < tmp + newImageH / 2; j++) {
            for (i = 0; i < imageW; i++) {
                yuv[count++] = data[j * imageW + i];
            }
        }
        ALOGE("YUV420spCrop end");
        return yuv;
    }
    
    
    uint8_t *VideoRecorderImpl::rotateYUV420Degree180(const uint8_t *data, int imageWidth,
                                                      int imageHeight) {
        uint8_t *yuv = new uint8_t[imageWidth * imageHeight * 3 / 2];
        int i = 0;
        int count = 0;
        
        for (i = imageWidth * imageHeight - 1; i >= 0; i--) {
            yuv[count] = data[i];
            count++;
        }
        
        i = imageWidth * imageHeight * 3 / 2 - 1;
        for (i = imageWidth * imageHeight * 3 / 2 - 1; i >= imageWidth
             * imageHeight; i -= 2) {
            yuv[count++] = data[i - 1];
            yuv[count++] = data[i];
        }
        return yuv;
    }
    
    uint8_t *VideoRecorderImpl::YUV420spRotate90(const uint8_t *data, int imageWidth,
                                                 int imageHeight) {
        ALOGE("YUV420spRotate90 imageWidth = %d, imageHeight = %d", imageWidth, imageHeight);
        uint8_t *yuv = new uint8_t[imageWidth * imageHeight * 3 / 2];
        // Rotate the Y luma
        int i = 0;
        for (int x = 0; x < imageWidth; x++) {
            for (int y = imageHeight - 1; y >= 0; y--) {
                yuv[i] = data[y * imageWidth + x];
                i++;
            }
            
        }
        // Rotate the U and V color components
        i = imageWidth * imageHeight * 3 / 2 - 1;
        for (int x = imageWidth - 1; x > 0; x = x - 2) {
            for (int y = 0; y < imageHeight / 2; y++) {
                yuv[i] = data[(imageWidth * imageHeight) + (y * imageWidth) + x];
                i--;
                yuv[i] = data[(imageWidth * imageHeight) + (y * imageWidth)
                              + (x - 1)];
                i--;
            }
        }
        return yuv;
    }
    
    uint8_t *VideoRecorderImpl::YUV420spRotateNegative90(const uint8_t *data, int imageWidth,
                                                         int imageHeight) {
        uint8_t *yuv = new uint8_t[imageWidth * imageHeight * 3 / 2];
        int nWidth = 0, nHeight = 0;
        int wh = 0;
        int uvHeight = 0;
        if (imageWidth != nWidth || imageHeight != nHeight) {
            nWidth = imageWidth;
            nHeight = imageHeight;
            wh = imageWidth * imageHeight;
            uvHeight = imageHeight >> 1;// uvHeight = height / 2
        }
        
        // 旋转Y
        int k = 0;
        for (int i = 0; i < imageWidth; i++) {
            int nPos = 0;
            for (int j = 0; j < imageHeight; j++) {
                yuv[k] = data[nPos + i];
                k++;
                nPos += imageWidth;
            }
        }
        
        for (int i = 0; i < imageWidth; i += 2) {
            int nPos = wh;
            for (int j = 0; j < uvHeight; j++) {
                yuv[k] = data[nPos + i];
                yuv[k + 1] = data[nPos + i + 1];
                k += 2;
                nPos += imageWidth;
            }
        }
        
        return rotateYUV420Degree180(yuv, imageWidth, imageHeight);
    }
    
    uint8_t *VideoRecorderImpl::YUV420spRotate90(const uint8_t *src, int srcWidth, int height,
                                                 int mode) {
        switch (mode) {
            case 1:
                return YUV420spRotate90(src, srcWidth, height);
            case -1:
                return YUV420spRotateNegative90(src, srcWidth, height);
            default:
                return NULL;
        }
    }
    
    
    int VideoRecorderImpl::init_filters(const char *filters_descr) {
        char args[512];

        
        int ret = 0;
        dec_ctx = video_st->codec;
        AVFilter *buffersrc = avfilter_get_by_name("buffer");
        AVFilter *buffersink = avfilter_get_by_name("buffersink");
        AVFilterInOut *outputs = avfilter_inout_alloc();
        AVFilterInOut *inputs = avfilter_inout_alloc();
        enum AVPixelFormat pix_fmts[] = {AV_PIX_FMT_YUV420P, AV_PIX_FMT_NONE};
        
        if (!buffersrc || !buffersink) {
            ALOGE("filtering source or sink element not found\n");
            ret = AVERROR_UNKNOWN;
            goto end;
        }
        
        
        filter_graph = avfilter_graph_alloc();
        if (!outputs || !inputs || !filter_graph) {
            ret = AVERROR(ENOMEM);
            goto end;
        }
        
        /* buffer video source: the decoded frames from the decoder will be inserted here. */
        snprintf(args, sizeof(args),
                 "video_size=%dx%d:pix_fmt=%d:time_base=%d/%d:pixel_aspect=%d/%d",
                 video_srcHight, video_width, dec_ctx->pix_fmt,
                 dec_ctx->time_base.num, dec_ctx->time_base.den,
                 dec_ctx->sample_aspect_ratio.num, dec_ctx->sample_aspect_ratio.den);
        
        ret = avfilter_graph_create_filter(&buffersrc_ctx, buffersrc, "in",
                                           args, NULL, filter_graph);
        if (ret < 0) {
            ALOGE("Cannot create buffer source\n");
            goto end;
        }
        
        /* buffer video sink: to terminate the filter chain. */
        ret = avfilter_graph_create_filter(&buffersink_ctx, buffersink, "out",
                                           NULL, NULL, filter_graph);
        if (ret < 0) {
            ALOGE("Cannot create buffer sink\n");
            goto end;
        }
        
        ret = av_opt_set_int_list(buffersink_ctx, "pix_fmts", pix_fmts,
                                  AV_PIX_FMT_YUV420P, AV_OPT_SEARCH_CHILDREN);
        if (ret < 0) {
            ALOGE("Cannot set output pixel format\n");
            goto end;
        }
        
        /*
         * Set the endpoints for the filter graph. The filter_graph will
         * be linked to the graph described by filters_descr.
         */
        
        /*
         * The buffer source output must be connected to the input pad of
         * the first filter described by filters_descr; since the first
         * filter input label is not specified, it is set to "in" by
         * default.
         */
        outputs->name = av_strdup("in");
        outputs->filter_ctx = buffersrc_ctx;
        outputs->pad_idx = 0;
        outputs->next = NULL;
        /*
         * The buffer sink input must be connected to the output pad of
         * the last filter described by filters_descr; since the last
         * filter output label is not specified, it is set to "out" by
         * default.
         */
        inputs->name = av_strdup("out");
        inputs->filter_ctx = buffersink_ctx;
        inputs->pad_idx = 0;
        inputs->next = NULL;
        if ((ret = avfilter_graph_parse_ptr(filter_graph, filters_descr,
                                            &inputs, &outputs, NULL)) < 0)
            goto end;
        if ((ret = avfilter_graph_config(filter_graph, NULL)) < 0)
            goto end;
    end:
        avfilter_inout_free(&inputs);
        avfilter_inout_free(&outputs);
        
        return ret;
    }
    
    
    void VideoRecorderImpl::SupplyVideoFrame(const void *frameData, unsigned long timestamp) {
        if (!isRecording)
            return;
        int ret;
        if (!video_st) {
            ALOGE("tried to SupplyVideoFrame when no video stream was present\n");
            return;
        }
        CMyLock lock(g_Lock);
        AVCodecContext *videoSupplyContext = video_st->codec;
        avpicture_fill(&src_picture, (uint8_t *) frameData, video_pixfmt, video_srcHight,
                       video_width);
        // if the input pixel format is not YUV420P, we'll assume
        // it's stored in tmp_picture, so we'll convert it to YUV420P
        // and store it in "picture"
        // if it's already in YUV420P format we'll assume it's stored in
        // "picture" from before
        if (video_pixfmt != AV_PIX_FMT_YUV420P) {
            
            sws_scale(img_convert_ctx, src_picture.data, src_picture.linesize, 0,
                      video_width, dst_picture.data, dst_picture.linesize);
        } else {
            av_picture_copy(&dst_picture, &src_picture, video_pixfmt, video_srcHight, video_width);
        }
        /**
         * add video filter start
         */
        if (av_buffersrc_add_frame_flags(buffersrc_ctx, picture, AV_BUFFERSRC_FLAG_KEEP_REF) < 0) {
            ALOGE("Error while feeding the filtergraph\n");
        }
        //        while (1) {
        ret = av_buffersink_get_frame(buffersink_ctx, filter_picture);
        
        if (ret < 0) {
            ALOGE("Error av_buffersink_get_frame\n");
            return;
        }
        
        // ---------------------------------------
        
        AVPacket pkt = {0};
        int got_packet;
        av_init_packet(&pkt);
        
        /* encode the image */
        filter_picture->pts = 90 * timestamp; // assuming millisecond timestamp and 90 kHz timebase
        ret = avcodec_encode_video2(videoSupplyContext, &pkt, filter_picture, &got_packet);
        if (ret < 0) {
            ALOGE("Error encoding video frame\n");
            return;
        }
        
        if (videoSupplyContext->coded_frame->pts != AV_NOPTS_VALUE)
            pkt.pts = av_rescale_q(videoSupplyContext->coded_frame->pts, videoSupplyContext->time_base, video_st->time_base);
        
        /* If size is zero, it means the image was buffered. */
        
        if (got_packet) {
            ret = write_frame(oc, &videoSupplyContext->time_base, video_st, &pkt);
            isRecordVideo = true;
            video_samples_count++;
        } else {
            ret = 0;
        }
        av_packet_unref(&pkt);
        
        // ---------------------------------------
        av_frame_unref(filter_picture);
        //        }
        
        /**
         * add video filter end
         */
        
    }
    
    VideoRecorder *VideoRecorder::New() {
        return (VideoRecorder *) (new VideoRecorderImpl);
    }
    
} // namespace AVR


AVR::VideoRecorder *recorder;

int initRecorder(char *fileName, int srcHight, int outputHeight, int cameraSelection, long audioBitrate,
                 long videoBitrate, int hasAudio, char *overlayName) {
    
    recorder = new AVR::VideoRecorderImpl();
    //mProfile.audioBitRate = 96000 , mProfile.audioSampleRate = 48000 , mProfile.videoBitRate = 6000000 , mProfile.videoFrameRate = 30
    ALOGE("fileName is %s , audioBitrate is %d , videoBitrate is %d , srcHight is %d , outputHeight is %d , cameraSelection is %d , overlayName is %s",
        fileName, audioBitrate, videoBitrate, srcHight, outputHeight, cameraSelection, overlayName);
    recorder->SetAudioOptions(AVR::AudioSampleFormatS16, 1, 44100, audioBitrate);
    recorder->SetVideoOptions(AVR::VideoFrameFormatNV12, overlayName, 480, outputHeight, srcHight, cameraSelection,videoBitrate);
    
    if (hasAudio > 0)
        recorder->Open(fileName, true, true);
    else
        recorder->Open(fileName, false, true);
    
    return 0;
}

int setRecorderInfo(int srcHight, int cameraSelection) {
    recorder->SetVideoOptionsInfo(srcHight, cameraSelection);
    return 0;
}

int recordeVideo(const void *frame, unsigned long timestamp) {
    //	const void *frame, unsigned long numBytes, unsigned long timestamp
    recorder->SupplyVideoFrame(frame, timestamp);
    return 0;
}

int recordeAudio(void *samples, unsigned long numSamples) {
    //	const void *samples, unsigned long numSamples
    recorder->SupplyAudioSamples(samples, numSamples);
    return 0;
}

int recordeClose() {
    int ret = 0;
    recorder->Close();
    ALOGV("recordeClose()\n");
    delete recorder;
    
    return ret;
}


#ifdef TESTING

float t = 0;
float tincr = 2 * M_PI * 110.0 / 44100;
float tincr2 = 2 * M_PI * 110.0 / 44100 / 44100;

void fill_audio_frame(int16_t *samples, int frame_size, int nb_channels)
{
    int j, i, v;
    int16_t *q;
    
    q = samples;
    for (j = 0; j < frame_size; j++) {
        v = (int)(sin(t) * 10000);
        for (i = 0; i < nb_channels; i++)
            *q++ = v;
        t += tincr;
        tincr += tincr2;
    }
}

void fill_yuv_image(AVFrame *pict, int frame_index, int width, int height)
{
    int x, y, i;
    
    i = frame_index;
    
    /* Y */
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            pict->data[0][y * pict->linesize[0] + x] = x + y + i * 3;
        }
    }
    
    /* Cb and Cr */
    for (y = 0; y < height / 2; y++) {
        for (x = 0; x < width / 2; x++) {
            pict->data[1][y * pict->linesize[1] + x] = 128 + y + i * 2;
            pict->data[2][y * pict->linesize[2] + x] = 64 + x + i * 5;
        }
    }
}

#define RGB565(r,g,b) (uint16_t)( ((red & 0x1F) << 11) | ((green & 0x3F) << 5) | (blue & 0x1F) )

void fill_rgb_image(uint8_t *pixels, int i, int width, int height)
{
    int x, y;
    
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            
            uint8_t red = x + y + i * 3;
            uint8_t green = x + y + i * 3;
            uint8_t blue = x + y + i * 3;
            
            uint16_t pixel = RGB565(red, green, blue);
            
            // assume linesize is width*2
            pixels[y * (width * 2) + x * 2 + 0] = (uint8_t)(pixel);		// lower order bits
            pixels[y * (width * 2) + x * 2 + 1] = (uint8_t)(pixel >> 8);	// higher order bits
        }
    }
}

#include <iostream>

int main()
{
    AVR::VideoRecorder *recorder = new AVR::VideoRecorderImpl();
    
    recorder->SetAudioOptions(AVR::AudioSampleFormatS16, 1, 44100, 64000);
    recorder->SetVideoOptions(AVR::VideoFrameFormatRGB565LE, 480, 480, 640, 1, 400000);
    recorder->Open("testing.mp4", true, true);
    
    int16_t *sound_buffer = new int16_t[2048 * 2];
    uint8_t *video_buffer = new uint8_t[640 * 480 * 2];
    for (int i = 0; i < 200; i++) {
        fill_audio_frame(sound_buffer, 900, 2);
        recorder->SupplyAudioSamples(sound_buffer, 900);
        
        fill_rgb_image(video_buffer, i, 640, 480);
        recorder->SupplyVideoFrame(video_buffer, (25 * i) + 1);
    }
    
    delete video_buffer;
    delete sound_buffer;
    
    recorder->Close();
    
    std::cout << "Done" << std::endl;
    
    delete recorder;
    
    return 0;
}

#endif

