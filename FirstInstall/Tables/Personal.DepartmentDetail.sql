USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Personal].[DepartmentDetail]
(
        [DP_ID]          UniqueIdentifier      NOT NULL,
        [DP_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [DP_NAME]        VarChar(50)           NOT NULL,
        [DP_FULL]        VarChar(250)          NOT NULL,
        [DP_DATE]        SmallDateTime         NOT NULL,
        [DP_END]         SmallDateTime             NULL,
        [DP_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Department] PRIMARY KEY CLUSTERED ([DP_ID]),
        CONSTRAINT [FK_Department_Department] FOREIGN KEY  ([DP_ID_MASTER]) REFERENCES [Personal].[Department] ([DPMS_ID])
);GO
