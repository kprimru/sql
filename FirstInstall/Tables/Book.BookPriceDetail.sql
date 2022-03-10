USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Book].[BookPriceDetail]
(
        [BP_ID]          UniqueIdentifier      NOT NULL,
        [BP_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [BP_ID_HALF]     UniqueIdentifier      NOT NULL,
        [BP_PRICE]       Money                 NOT NULL,
        [BP_DATE]        SmallDateTime         NOT NULL,
        [BP_END]         SmallDateTime             NULL,
        [BP_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Book.BookPriceDetail] PRIMARY KEY CLUSTERED ([BP_ID]),
        CONSTRAINT [FK_Book.BookPriceDetail(BP_ID_MASTER)_Book.BookPrice(BPMS_ID)] FOREIGN KEY  ([BP_ID_MASTER]) REFERENCES [Book].[BookPrice] ([BPMS_ID]),
        CONSTRAINT [FK_Book.BookPriceDetail(BP_ID_HALF)_Book.Half(HLFMS_ID)] FOREIGN KEY  ([BP_ID_HALF]) REFERENCES [Common].[Half] ([HLFMS_ID])
);GO
