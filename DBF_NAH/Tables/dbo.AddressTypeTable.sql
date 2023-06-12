USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AddressTypeTable]
(
        [AT_ID]       TinyInt       Identity(1,1)   NOT NULL,
        [AT_NAME]     VarChar(50)                   NOT NULL,
        [AT_ACTIVE]   Bit                           NOT NULL,
        CONSTRAINT [PK_dbo.AddressTypeTable] PRIMARY KEY CLUSTERED ([AT_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.AddressTypeTable(AT_NAME)] ON [dbo].[AddressTypeTable] ([AT_NAME] ASC);
GO
