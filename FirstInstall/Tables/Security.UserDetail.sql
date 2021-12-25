USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[UserDetail]
(
        [US_ID]          UniqueIdentifier      NOT NULL,
        [US_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [US_LOGIN]       VarChar(50)           NOT NULL,
        [US_NAME]        VarChar(50)           NOT NULL,
        [US_NOTE]        VarChar(250)          NOT NULL,
        [US_DATE]        SmallDateTime         NOT NULL,
        [US_END]         SmallDateTime             NULL,
        [US_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_UserDetail] PRIMARY KEY CLUSTERED ([US_ID]),
        CONSTRAINT [FK_UserDetail_Users] FOREIGN KEY  ([US_ID_MASTER]) REFERENCES [Security].[Users] ([USMS_ID])
);GO
