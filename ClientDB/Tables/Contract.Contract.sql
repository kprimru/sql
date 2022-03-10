USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[Contract]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [NUM]           Int                       NULL,
        [NUM_S]         NVarChar(256)         NOT NULL,
        [ID_TYPE]       UniqueIdentifier      NOT NULL,
        [ID_VENDOR]     UniqueIdentifier      NOT NULL,
        [REG_DATE]      SmallDateTime         NOT NULL,
        [DATE]          SmallDateTime             NULL,
        [NOTE]          NVarChar(Max)         NOT NULL,
        [ID_YEAR]       UniqueIdentifier      NOT NULL,
        [ID_CLIENT]     Int                       NULL,
        [CLIENT]        NVarChar(1024)            NULL,
        [RETURN_DATE]   SmallDateTime             NULL,
        [ID_STATUS]     UniqueIdentifier      NOT NULL,
        [STATUS]        SmallInt              NOT NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        [LAW]           NVarChar(Max)             NULL,
        [DateFrom]      SmallDateTime             NULL,
        [DateTo]        SmallDateTime             NULL,
        [SignDate]      SmallDateTime             NULL,
        CONSTRAINT [PK_Contract.Contract] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Contract.Contract(ID_STATUS)_Contract.Status(ID)] FOREIGN KEY  ([ID_STATUS]) REFERENCES [Contract].[Status] ([ID]),
        CONSTRAINT [FK_Contract.Contract(ID_TYPE)_Contract.Type(ID)] FOREIGN KEY  ([ID_TYPE]) REFERENCES [Contract].[Type] ([ID]),
        CONSTRAINT [FK_Contract.Contract(ID_VENDOR)_Contract.Vendor(ID)] FOREIGN KEY  ([ID_VENDOR]) REFERENCES [dbo].[Vendor] ([ID]),
        CONSTRAINT [FK_Contract.Contract(ID_YEAR)_Contract.Period(ID)] FOREIGN KEY  ([ID_YEAR]) REFERENCES [Common].[Period] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Contract.Contract(DateTo)] ON [Contract].[Contract] ([DateTo] ASC);
CREATE NONCLUSTERED INDEX [IX_Contract.Contract(ID_VENDOR)+(NUM,ID_YEAR)] ON [Contract].[Contract] ([ID_VENDOR] ASC) INCLUDE ([NUM], [ID_YEAR]);
CREATE NONCLUSTERED INDEX [IX_Contract.Contract(ID_VENDOR,ID_YEAR)+(NUM)] ON [Contract].[Contract] ([ID_VENDOR] ASC, [ID_YEAR] ASC) INCLUDE ([NUM]);
GO
