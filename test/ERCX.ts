import {ethers} from "hardhat";
import {expect, use} from 'chai';
import {SignerWithAddress} from "@nomiclabs/hardhat-ethers/signers";
import {ERCXMock} from "../typechain/ERCXMock";
import { BigNumber } from "ethers";
const {constants} = require('@openzeppelin/test-helpers');
const {ZERO_ADDRESS} = constants;



describe("Ercx", async () => {
	let owner: SignerWithAddress, approved: SignerWithAddress, operator: SignerWithAddress, user: SignerWithAddress,
		other: SignerWithAddress;
    let ercx: ERCXMock;
	let snapshotId: any;
	let tokenID = Math.floor(Math.random()*1000); // The first minted NFT
	let nonExistentTokenId = 1001;
	
	
	context('with minted tokens',function(){
		before(async () => {
			const signers = await ethers.getSigners();
			owner = signers[0];
			approved = signers[1];
			operator = signers[2];
			user = signers[3];
			other = signers[4];
			
			
			const ERCX = await ethers.getContractFactory("ERCXMock");
			const deployedContract = await ERCX.deploy("sand","s");
			await deployedContract.deployed();
			ercx = deployedContract as ERCXMock;
			await ercx.safeMint(owner.address,tokenID);
			await ercx["safeTransferUserFrom(address,address,uint256)"](owner.address,user.address,tokenID);
		})
	
		beforeEach(async function () {
			snapshotId = await ethers.provider.send('evm_snapshot', []);
		});
	
		afterEach(async function () {
			await ethers.provider.send('evm_revert', [snapshotId]);
		});

		describe('safeMint',function(){
			let secondId = tokenID*2;
			let sameId = tokenID;
			let balance: BigNumber;
			let balanceOfUser:BigNumber;
			let logs:any;
			let to:string;

			it('reverts with a null destination address', async function () {
				await expect(ercx.safeMint(ZERO_ADDRESS,secondId)).to.be.revertedWith("ERCX: mint to the zero address");
			})

			it('reverts when adding a token id that already exists',async function () {
				await expect(ercx.safeMint(owner.address,sameId)).to.be.revertedWith("ERC721: token already minted");
			})

			const mintSuccessful = function(){
				it('adjust balance', async function () {
					expect(await ercx.balanceOfUser(to)).to.be.equal(balanceOfUser.add(1));
					expect(await ercx.balanceOf(to)).to.be.equal(balance.add(1))
				})

				it('emit a Transfer event',async function () {
					await expect(logs).emit(ercx,'Transfer').withArgs(ZERO_ADDRESS,to,secondId);
				})

				it('emit a TransferUser event',async function () {
					await expect(logs).emit(ercx,'TransferUser').withArgs(ZERO_ADDRESS,to,secondId);
				})
			}

			context('when the address has token use right already',function(){
				beforeEach(async function () {
					balance = await ercx.balanceOf(user.address);
					balanceOfUser = await ercx.balanceOfUser(user.address);
					logs = await ercx.safeMint(user.address,secondId);
					to = user.address;
				})

				mintSuccessful();
			})

			context('when mint to a new address',function(){
				beforeEach(async function () {
					balance = await ercx.balanceOf(other.address);
					balanceOfUser = await ercx.balanceOfUser(other.address);
					logs = await ercx.safeMint(other.address,secondId);
					to = other.address;
				})

				mintSuccessful();
			})
		})

		describe('burn',function(){
			let secondId = tokenID*2;
			let balance: BigNumber;
			let balanceOfUser:BigNumber;
			let logs:any;
			let ownerAddress:string;
			let userAddress:string;
			let delId:number;

			it('revert when burn a non-exist token',async function () {
				await expect(ercx.burn(nonExistentTokenId))
				.to.be.revertedWith("ERC721: owner query for nonexistent token");
			})

			const burnSuccessful = function(){
				it('adjust balance',async function () {
					expect(await ercx.balanceOf(ownerAddress)).to.be.equal(balance.sub(1));
					expect(await ercx.balanceOfUser(userAddress)).to.be.equal(balanceOfUser.sub(1));
				})

				it('emit an Approval event',async function () {
					await expect(logs).to.emit(ercx,"Approval").withArgs(ownerAddress,ZERO_ADDRESS,delId);
				})

				it('emit an ApprovalUser event',async function () {
					await expect(logs).to.emit(ercx,"ApprovalUser").withArgs(await ercx.signer.getAddress(),ZERO_ADDRESS,delId);
				})

				it('emit a Transfer event',async function () {
					await expect(logs).to.emit(ercx,'Transfer').withArgs(ownerAddress,ZERO_ADDRESS,delId);
				})

				it('emit a TransferUser event',async function () {
					await expect(logs).to.emit(ercx,'TransferUser').withArgs(userAddress,ZERO_ADDRESS,delId);
				})

				it('when call userOf, it revert',async function () {
					await expect(ercx.userOf(delId))
					.to.be.revertedWith("ERCX: user query for nonexistent token");

					await expect(ercx.ownerOf(delId))
					.to.be.revertedWith("ERC721: owner query for nonexistent token");
				})
			}

			context('with minted token',async function () {
				context('with more token',async function () {
					beforeEach(async function () {
						await ercx.safeMint(owner.address,secondId);
						balanceOfUser = await ercx.balanceOfUser(await ercx.userOf(tokenID));
						balance = await ercx.balanceOf(await ercx.ownerOf(tokenID))
						userAddress = await ercx.userOf(tokenID);
						ownerAddress = await ercx.ownerOf(tokenID);
						delId = tokenID;
						logs = await ercx.burn(tokenID);
					})
	
					burnSuccessful();
				})
				
				context('with last token',async function () {
					beforeEach(async function () {
						balanceOfUser = await ercx.balanceOfUser(await ercx.userOf(tokenID));
						balance = await ercx.balanceOf(await ercx.ownerOf(tokenID))
						userAddress = await ercx.userOf(tokenID);
						ownerAddress = await ercx.ownerOf(tokenID);
						delId = tokenID;
						logs = await ercx.burn(tokenID);
					})
	
					burnSuccessful();
				})
			})
		})
		
		describe("balanceOfUser",function(){
			context('when the given address has some tokens use right', function () {
				it('returns the amount of tokens available for the given address', async function () {
				  expect(await ercx.balanceOfUser(user.address)).to.be.equal(1);
				});
			  });
		
			  context('when the given address does not have any tokens use right', function () {
				it('returns 0', async function () {
				  expect(await ercx.balanceOfUser(other.address)).to.be.equal(0);
				});
			  });
		
			  context('when querying the zero address', function () {
				it('throws', async function () {
					await expect(ercx.balanceOfUser(ZERO_ADDRESS)).to.be.revertedWith('ERCX: balance query for the zero address');
				});
			  });
		});

		describe("userOf",function(){
			context('when the given token ID was tracked by this token', function () {
				it('returns the owner of the given token ID', async function () {
				  expect(await ercx.userOf(tokenID)).to.be.equal(user.address);
				});
			  });
		
			  context('when the given token ID was not tracked by this token', function () {
				it('reverts', async function () {
					await expect(ercx.userOf(nonExistentTokenId)).to.be.revertedWith("ERCX: user query for nonexistent token");
				});
			  });
		});

		describe('approve', function(){
			describe('approveUser', function () {
	
				let logs: any;
				const itClearsApproval = function () {
				  it('clears approval for the token', async function () {
					expect(await ercx.getApprovedUser(tokenID)).to.be.equal(ZERO_ADDRESS);
				  });
				};
		  
				const itApproves = function (signId: any) {
				  let address: string;
				  
				  it('sets the approval for the target address', async function () {
					switch(signId){
						case 0:
							address = owner.address;
							break;
						case 1:
							address = approved.address;
							break;
						case 2:
							address = operator.address;
							break;
						case 3:
							address = user.address;
							break;
						case 4:
							address = other.address;
							break;
					}
					expect(await ercx.getApprovedUser(tokenID)).to.be.equal(address);
				  });
				};
		  
				const itEmitsApprovalUserEvent = function (signId: any) {
					let address: string;
				  
				  it('emits an ApprovalUser event', async function () {
					switch(signId){
						case 0:
							address = owner.address;
							break;
						case 1:
							address = approved.address;
							break;
						case 2:
							address = operator.address;
							break;
						case 3:
							address = user.address;
							break;
						case 4:
							address = other.address;
							break;
						case 5:
							address = ZERO_ADDRESS;
							break;
					}
					await expect(logs).to.emit(ercx,"ApprovalUser").withArgs(await ercx.signer.getAddress(),address,tokenID);
				  });
				};
		  
				context('when clearing approval', function () {
				  context('when there was no prior approval', function () {
					beforeEach(async function () {
					  logs  = await ercx.approveUser(ZERO_ADDRESS, tokenID);
					});
		  
					itClearsApproval();
					itEmitsApprovalUserEvent(5);
				  });
		  
				  context('when there was a prior approval', function () {
					beforeEach(async function () {
					  await ercx.approveUser(approved.address, tokenID);
					  logs  = await ercx.approveUser(ZERO_ADDRESS, tokenID);
					});
		  
					itClearsApproval();
					itEmitsApprovalUserEvent(5);
				  });
				});
		  
				context('when approving a non-zero address', function () {
				  context('when there was no prior approval', function () {
					beforeEach(async function () {
					  logs  = await ercx.approveUser(approved.address, tokenID);
					});				
					itApproves(1);
					itEmitsApprovalUserEvent(1);
				  });
		  
				  context('when there was a prior approval to the same address', function () {
					beforeEach(async function () {
					  await ercx.approveUser(approved.address, tokenID);
					  logs  = await ercx.approveUser(approved.address, tokenID);
					});
		  
					itApproves(1);
					itEmitsApprovalUserEvent(1);
				  });
		  
				  context('when there was a prior approval to a different address', function () {
					beforeEach(async function () {
					  await ercx.approveUser(approved.address, tokenID);
					  logs  = await ercx.approveUser(other.address, tokenID);
					});
					itApproves(4);
					itEmitsApprovalUserEvent(4);
				  });
				});
		  
				context('when the address that receives the approval is the user', function () {
				  it('reverts', async function () {
					await expect(
					  ercx.approveUser(user.address, tokenID)
					).to.revertedWith('ERCX: approval to current user');
				  });
				});
		  
				context('when the sender is approved for the given token ID', function () {
					beforeEach(async function(){
						await ercx.approve(approved.address, tokenID);
						ercx = ercx.connect(approved);
						logs = await ercx.approveUser(other.address, tokenID);
					});
					afterEach(async function () {
						ercx = ercx.connect(owner);
					})
					itApproves(4);
					itEmitsApprovalUserEvent(4);
				});
	
				context('when the sender is user-approved for the given token ID', function () {
					beforeEach(async function(){
						await ercx.approveUser(approved.address, tokenID);
						ercx = ercx.connect(approved);
						logs = await ercx.approveUser(other.address, tokenID);
					});
					afterEach(async function () {
						ercx = ercx.connect(owner);
					})
					itApproves(4);
					itEmitsApprovalUserEvent(4);
				});
	
				context('when the sender is user for the given token ID', function () {
					beforeEach(async function(){
						ercx = ercx.connect(user);
						logs = await ercx.approveUser(approved.address, tokenID);
					});
					afterEach(async function () {
						ercx = ercx.connect(owner);
					})
					itApproves(1);
					itEmitsApprovalUserEvent(1);
				});
	
				context('when the sender is not owner nor user nor approved for all', function () {
					it('reverts', async function () {
					  await expect(ercx.connect(other).approveUser(approved.address, tokenID)
					  ).to.revertedWith('ERCX: approve caller is not owner nor approved for all');
					});
				  });
		  
				context('when the given token ID does not exist', function () {
				  it('reverts', async function () {
					await expect(ercx.approveUser(approved.address, nonExistentTokenId)
					).to.revertedWith("ERCX: user query for nonexistent token");
				  });
				});
			});
	
			describe('getApprovedUser', function () {
				context('when token is not minted', async function () {
					it('reverts', async function () {
					await expect(
						ercx.getApprovedUser(nonExistentTokenId)
					).to.revertedWith('ERCX: approved query for nonexistent token');
					});
				});
			
				context('when token has been minted ', async function () {
					it('should return the zero address', async function () {
					expect(await ercx.getApprovedUser(tokenID)).to.be.equal(ZERO_ADDRESS);
					});
			
					context('when account has been approved', async function () {
						beforeEach(async function () {
							await ercx.approveUser(approved.address, tokenID);
						});
				
						it('returns approved account', async function () {
							expect(await ercx.getApprovedUser(tokenID)).to.be.equal(approved.address);
						});
					});
				});
			});
		})
		
		describe('transferUser', function () {
			let logs: any;
			let to: string;
			let from: string;
	  
			beforeEach(async function () {
			  await ercx.approveUser(approved.address,tokenID);
			  ercx = ercx.connect(user);
			});

			afterEach(async function () {
				ercx = ercx.connect(owner);
			})
	  
			const transferWasSuccessful = function () {
			  it('transfers the use right of the given token ID to the given address', async function () {
				expect(await ercx.userOf(tokenID)).to.be.equal(to);
			  });
	  
			  it('emits a TransferUser event', async function () {
				await expect(logs).to.emit(ercx,'TransferUser').withArgs(from,to,tokenID);
			  });
	  
			  it('clears the user-approval for the token ID', async function () {
				expect(await ercx.getApprovedUser(tokenID)).to.be.equal(ZERO_ADDRESS);
			  });
	  
			  it('emits an Approval User event', async function () {
				await expect(logs).to.emit(ercx,'ApprovalUser').withArgs(await ercx.signer.getAddress(),ZERO_ADDRESS,tokenID);
			  });
	  
			  it('adjusts user balances', async function () {
				expect(await ercx.balanceOfUser(from)).to.be.equal(0);
				expect(await ercx.balanceOfUser(to)).to.be.equal(1);
			  });
			};

			context('when called by the owner individual', function () {
			beforeEach(async function () {
				ercx = ercx.connect(owner);
				logs = await ercx["safeTransferUserFrom(address,address,uint256)"](user.address,other.address,tokenID);
				from = user.address;
				to = other.address;
			});
			transferWasSuccessful();
			});

			context('when called by the user individual', function () {
			beforeEach(async function () {
				logs = await ercx["safeTransferUserFrom(address,address,uint256)"](user.address,other.address,tokenID);
				from = user.address;
				to = other.address;
			});
			transferWasSuccessful();
			});
			
			context('when called by the approved individual', function () {
			beforeEach(async function () {
				await ercx.approveUser(ZERO_ADDRESS,tokenID);
				await ercx.connect(owner).approve(approved.address,tokenID);
				ercx = ercx.connect(approved);
				logs = await ercx["safeTransferUserFrom(address,address,uint256)"](user.address,other.address,tokenID);
				from = user.address;
				to = other.address;
			});
			transferWasSuccessful();
			});

			context('when called by the user-approved individual', function () {
			beforeEach(async function () {
				ercx = ercx.connect(approved);
				logs = await ercx["safeTransferUserFrom(address,address,uint256)"](user.address,other.address,tokenID);
				from = user.address;
				to = other.address;
			});
			transferWasSuccessful();
			});

			context('when called by not authorized individual', function () {
			it('reverts', async function () {
				await expect(ercx.connect(other)["safeTransferUserFrom(address,address,uint256)"](user.address,other.address,tokenID))
				.to.be.revertedWith("ERCX: transfer caller is not user or owner nor approved");
			});
			});
	
			context('when transfer to the user', function () {
			beforeEach(async function () {
				logs = await ercx["safeTransferUserFrom(address,address,uint256)"](user.address,user.address,tokenID);
				from = user.address;
				to = user.address;
			});
	
			it('keeps usership of the token', async function () {
				expect(await ercx.userOf(tokenID)).to.be.equal(user.address);
			});
	
			it('clears the approval for the token ID', async function () {
				expect(await ercx.getApprovedUser(tokenID)).to.be.equal(ZERO_ADDRESS);
			});
	
			it('emits only a transferUser event', async function () {
				await expect(logs).to.emit(ercx,'TransferUser').withArgs(from,to,tokenID);
			});
	
			it('keeps the user balance', async function () {
				expect(await ercx.balanceOfUser(user.address)).to.be.equal(1);
			});
			});
	
			context('when the address of the previous user is incorrect', function () {
			it('reverts', async function () {
				await expect(ercx["safeTransferUserFrom(address,address,uint256)"](other.address,other.address,tokenID))
				.to.be.revertedWith("ERCX: transfer of token that is not use");
			});
			});
	
			context('when the given token ID does not exist', function () {
			it('reverts', async function () {
				await expect(ercx["safeTransferUserFrom(address,address,uint256)"](user.address,other.address,nonExistentTokenId))
				.to.be.revertedWith("ERCX: operator query for nonexistent token");
			});
			});
	
			context('when the to-address is the zero address', function () {
			it('reverts', async function () {
				await expect(ercx["safeTransferUserFrom(address,address,uint256)"](user.address,ZERO_ADDRESS,tokenID))
				.to.be.revertedWith("ERCX: transfer to the zero address");
			});
			});
		});

		describe('transferAll', function(){
			let logs: any;
			let to: string;
			let ownerAddress: string;
			let userAddress: string;

			afterEach(async function () {
				ercx = ercx.connect(owner);
			})
	  
			const transferAllWasSuccessful = function () {
			  it('transfers the owner and use right of the given token ID to the given address', async function () {
				expect(await ercx.userOf(tokenID)).to.be.equal(to);
				expect(await ercx.ownerOf(tokenID)).to.be.equal(to);
			  });
			  
			  it('emits a Transfer event', async function () {
				await expect(logs).to.emit(ercx,'Transfer').withArgs(ownerAddress,to,tokenID);
			  })

			  it('emits a TransferUser event', async function () {
				await expect(logs).to.emit(ercx,'TransferUser').withArgs(userAddress,to,tokenID);
			  });
	  
			  it('clears the approval for the token ID', async function () {
				expect(await ercx.getApprovedUser(tokenID)).to.be.equal(ZERO_ADDRESS);
				expect(await ercx.getApproved(tokenID)).to.be.equal(ZERO_ADDRESS);
			  });
	  
			  it('emits an ApprovalUser event', async function () {
				await expect(logs).to.emit(ercx,'ApprovalUser').withArgs(await ercx.signer.getAddress(),ZERO_ADDRESS,tokenID);
			  });

			  it('emits an Approval event', async function () {
				  await expect(logs).to.emit(ercx,'Approval').withArgs(ownerAddress,ZERO_ADDRESS,tokenID);
			  })
	  
			  it('adjusts owner and user balances', async function () {
				expect(await ercx.balanceOf(to)).to.be.equal(1);
				expect(await ercx.balanceOfUser(to)).to.be.equal(1);
				expect(await ercx.balanceOf(ownerAddress)).to.be.equal(0);
				expect(await ercx.balanceOfUser(userAddress)).to.be.equal(0);
			  });
			};

			context('when called by the owner individual',function(){
				context('when user and owner is the same address',function(){
					beforeEach(async function () {
						await ercx["safeTransferUserFrom(address,address,uint256)"](user.address,owner.address,tokenID);
						logs = await ercx["safeTransferAllFrom(address,address,uint256)"](owner.address,other.address,tokenID);
						to = other.address;
						ownerAddress = owner.address;
						userAddress = owner.address;
					})
	
					transferAllWasSuccessful();
				})
	
				context('when user and owner is not the same address',function(){
					beforeEach(async function () {
						logs = await ercx["safeTransferAllFrom(address,address,uint256)"](owner.address,other.address,tokenID);
						to = other.address;
						ownerAddress = owner.address;
						userAddress = user.address;
					})
	
					transferAllWasSuccessful();
				})
			})

			context('when called by the approved individual',function(){
				beforeEach(async function () {
					await ercx.approve(approved.address,tokenID);
					ercx = ercx.connect(approved);
					logs = await ercx["safeTransferAllFrom(address,address,uint256)"](owner.address,other.address,tokenID);
					to = other.address;
					ownerAddress = owner.address;
					userAddress = user.address;
				})

				transferAllWasSuccessful();
			})

			context('when called by the address that not owner nor approved',function(){
				context('when called by user',function(){
					it('revert',async function () {
						await expect(ercx.connect(user)["safeTransferAllFrom(address,address,uint256)"](owner.address,other.address,tokenID))
						.to.be.revertedWith("ERCX: transfer caller is not owner nor approved");
					})
				})
				
				context('when called by other',function(){
					it('revert',async function () {
						await expect(ercx.connect(other)["safeTransferAllFrom(address,address,uint256)"](owner.address,other.address,tokenID))
						.to.be.revertedWith("ERCX: transfer caller is not owner nor approved");
					})
				})
			})
		});
	
	})

    
});