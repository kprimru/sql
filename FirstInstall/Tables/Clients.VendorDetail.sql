USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Clients].[VendorDetail]
(
        [VD_ID]          UniqueIdentifier      NOT NULL,
        [VD_ID_MASTER]   UniqueIdentifier      NOT NULL,
        [VD_NAME]        VarChar(50)           NOT NULL,
        [VD_DATE]        SmallDateTime         NOT NULL,
        [VD_END]         SmallDateTime             NULL,
        [VD_REF]         TinyInt               NOT NULL,
        CONSTRAINT [PK_Vendors] PRIMARY KEY CLUSTERED ([VD_ID]),
        CONSTRAINT [FK_Vendors_Vendors] FOREIGN KEY  ([VD_ID_MASTER]) REFERENCES [Clients].[Vendors] ([VDMS_ID])
);GO
