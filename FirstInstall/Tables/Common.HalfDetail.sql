USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[HalfDetail]
(
        [HLF_ID]           UniqueIdentifier      NOT NULL,
        [HLF_ID_MASTER]    UniqueIdentifier      NOT NULL,
        [HLF_NAME]         VarChar(50)           NOT NULL,
        [HLF_BEGIN_DATE]   SmallDateTime         NOT NULL,
        [HLF_END_DATE]     SmallDateTime         NOT NULL,
        [HLF_DATE]         SmallDateTime         NOT NULL,
        [HLF_END]          SmallDateTime             NULL,
        [HLF_REF]          TinyInt               NOT NULL,
        CONSTRAINT [PK_Common.HalfDetail] PRIMARY KEY CLUSTERED ([HLF_ID]),
        CONSTRAINT [FK_Common.HalfDetail(HLF_ID_MASTER)_Common.Half(HLFMS_ID)] FOREIGN KEY  ([HLF_ID_MASTER]) REFERENCES [Common].[Half] ([HLFMS_ID])
);GO
