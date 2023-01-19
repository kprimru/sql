USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Book].[BookBonusDetail]
(
        [BB_ID]          UniqueIdentifier      NOT NULL,
        [BB_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [BB_ID_PT]       UniqueIdentifier      NOT NULL,
        [BB_PERCENT]     decimal               NOT NULL,
        [BB_DATE]        SmallDateTime         NOT NULL,
        [BB_END]         SmallDateTime             NULL,
        [BB_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Book.BookBonusDetail] PRIMARY KEY CLUSTERED ([BB_ID]),
        CONSTRAINT [FK_Book.BookBonusDetail(BB_ID_MASTER)_Book.BookBonus(BBMS_ID)] FOREIGN KEY  ([BB_ID_MASTER]) REFERENCES [Book].[BookBonus] ([BBMS_ID]),
        CONSTRAINT [FK_Book.BookBonusDetail(BB_ID_PT)_Book.PersonalType(PTMS_ID)] FOREIGN KEY  ([BB_ID_PT]) REFERENCES [Personal].[PersonalType] ([PTMS_ID])
);
GO
