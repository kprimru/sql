USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Contract].[Agreement]
(
        [ID]            UniqueIdentifier      NOT NULL,
        [ID_CONTRACT]   UniqueIdentifier      NOT NULL,
        [NOTE]          NVarChar(Max)         NOT NULL,
        [ID_STATUS]     UniqueIdentifier      NOT NULL,
        [UPD_DATE]      DateTime              NOT NULL,
        [UPD_USER]      NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_Contract.Agreement] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Contract.Agreement(ID_CONTRACT)_Contract.Contract(ID)] FOREIGN KEY  ([ID_CONTRACT]) REFERENCES [Contract].[Contract] ([ID]),
        CONSTRAINT [FK_Contract.Agreement(ID_STATUS)_Contract.Status(ID)] FOREIGN KEY  ([ID_STATUS]) REFERENCES [Contract].[Status] ([ID])
);
GO
