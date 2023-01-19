USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Book].[BookDeliveryDetail]
(
        [BD_ID]          UniqueIdentifier      NOT NULL,
        [BD_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [BD_PRICE]       Money                 NOT NULL,
        [BD_COUNT]       SmallInt              NOT NULL,
        [BD_DATE]        SmallDateTime         NOT NULL,
        [BD_END]         SmallDateTime             NULL,
        [BD_REF]         TinyInt                   NULL,
        CONSTRAINT [PK_Book.BookDeliveryDetail] PRIMARY KEY CLUSTERED ([BD_ID]),
        CONSTRAINT [FK_Book.BookDeliveryDetail(BD_ID_MASTER)_Book.BookDelivery(BDMS_ID)] FOREIGN KEY  ([BD_ID_MASTER]) REFERENCES [Book].[BookDelivery] ([BDMS_ID])
);
GO
