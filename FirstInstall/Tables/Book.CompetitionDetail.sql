USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Book].[CompetitionDetail]
(
        [CP_ID]          UniqueIdentifier      NOT NULL,
        [CP_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [CP_ID_HALF]     UniqueIdentifier      NOT NULL,
        [CP_NAME]        VarChar(100)          NOT NULL,
        [CP_COUNT]       TinyInt               NOT NULL,
        [CP_BONUS]       Money                 NOT NULL,
        [CP_DATE]        SmallDateTime         NOT NULL,
        [CP_END]         SmallDateTime             NULL,
        [CP_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Book.CompetitionDetail] PRIMARY KEY CLUSTERED ([CP_ID]),
        CONSTRAINT [FK_Book.CompetitionDetail(CP_ID_MASTER)_Book.Competition(CPMS_ID)] FOREIGN KEY  ([CP_ID_MASTER]) REFERENCES [Book].[Competition] ([CPMS_ID]),
        CONSTRAINT [FK_Book.CompetitionDetail(CP_ID_HALF)_Book.Half(HLFMS_ID)] FOREIGN KEY  ([CP_ID_HALF]) REFERENCES [Common].[Half] ([HLFMS_ID])
);
GO
