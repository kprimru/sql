USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VMIReportTable]
(
        [VMR_ID]        Int            Identity(1,1)   NOT NULL,
        [VMR_RIC_NUM]   TinyInt                        NOT NULL,
        [VMR_TO_NUM]    Int                            NOT NULL,
        [VMR_TO_NAME]   VarChar(250)                   NOT NULL,
        [VMR_INN]       VarChar(50)                        NULL,
        [VMR_REGION]    TinyInt                            NULL,
        [VMR_CITY]      VarChar(40)                        NULL,
        [VMR_ADDR]      VarChar(250)                       NULL,
        [VMR_FIO_1]     VarChar(92)                        NULL,
        [VMR_JOB_1]     VarChar(100)                       NULL,
        [VMR_TELS_1]    VarChar(62)                        NULL,
        [VMR_FIO_2]     VarChar(92)                        NULL,
        [VMR_JOB_2]     VarChar(100)                       NULL,
        [VMR_TELS_2]    VarChar(62)                        NULL,
        [VMR_FIO_3]     VarChar(92)                        NULL,
        [VMR_JOB_3]     VarChar(100)                       NULL,
        [VMR_TELS_3]    VarChar(62)                        NULL,
        [VMR_FIO_4]     VarChar(92)                        NULL,
        [VMR_JOB_4]     VarChar(100)                       NULL,
        [VMR_TELS_4]    VarChar(62)                        NULL,
        [VMR_FIO_5]     VarChar(92)                        NULL,
        [VMR_JOB_5]     VarChar(100)                       NULL,
        [VMR_TELS_5]    VarChar(62)                        NULL,
        [VMR_SERV]      VarChar(50)                        NULL,
        [VMR_DISTR]     VarChar(500)                       NULL,
        [VMR_COMMENT]   VarChar(250)                       NULL,
        CONSTRAINT [PK_dbo.VMIReportTable] PRIMARY KEY CLUSTERED ([VMR_ID])
);
GO
